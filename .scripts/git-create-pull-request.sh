#!/bin/zsh

# Default values for optional parameters
local jira_ticket=""
local category=""
local platform="github"
local title=""

if [[ -z "$GIT_DEFAULT_BRANCH" ]]; then
  echo "Error: GIT_DEFAULT_BRANCH environment variable is not set."
  echo "Please set it to your main development branch (e.g., main, master, develop)."
  exit 1
fi

# --- Usage Function ---
usage() {
  echo "Usage: $0 \"<Your Title>\" [options]"
  echo "Creates a new git branch, commits changes, and opens a merge/pull request."
  echo "Options:"
  echo "  --jira-ticket \"<id>\"   Optional JIRA ticket ID (e.g., PROJ-123)."
  echo "  --category \"<name>\"    Optional category for the branch name (e.g., feat, fix, chore)."
  echo "  --platform \"<tool>\"    Platform for MR/PR. Options: 'gitlab' (default) or 'github'."
  echo "  -h, --help               Show this help message."
  exit 1
}

# --- Parse Command-Line Arguments ---
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -j|--jira-ticket)
      jira_ticket="$2"
      shift 2
      ;;
    -c|--category)
      category="$2"
      shift 2
      ;;
    -p|--platform)
      platform_input=$(echo "$2" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
      if [[ "$platform_input" == "gitlab" || "$platform_input" == "github" ]]; then
        platform="$platform_input"
      else
        echo "Error: Invalid value for --platform. Only 'github' and 'gitlab' are supported for now." >&2
        usage
      fi
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option: $arg" >&2;
      usage ;;
    *) # Positional argument (part of title)
      args_for_title+=("$arg") ;;
      echo "Argument: $arg"
  esac
done

echo ${args_for_title[@]}

if [[ ${#args_for_title[@]} -gt 0 ]]; then
  title="${args_for_title[*]}" # Joins with space by default with [*]
else
  # Title is mandatory, and now comes from positional args
  echo "Error: Title is a mandatory parameter and must be provided as positional arguments." >&2
  echo "Example: $0 \"Your Actual Title\" --category feat" >&2
  usage
fi

# --- Validate Mandatory Parameters ---
if [[ -z "$title" ]]; then
  echo "Error: --title is a mandatory parameter." >&2
  usage
fi

# --- Set Category Default ---
if [[ -z "$category" && -n "$GIT_DEFAULT_CATEGORY" ]]; then
  category="$GIT_DEFAULT_CATEGORY"
  echo "Info: Using default category '$category' from GIT_DEFAULT_CATEGORY."
elif [[ -z "$category" ]]; then
  echo "Info: No category provided and GIT_DEFAULT_CATEGORY is not set. Branch will not have a category prefix."
fi

# --- Construct Branch Name ---
sanitized_title=$(echo "$title" | tr '[:space:]' '-' | tr -cs 'a-zA-Z0-9_.-' '-' | sed 's/--\+/-/g' | sed 's/^-//;s/-$//')

echo "Info: Sanitized title: $sanitized_title"
echo "Info: Category: $category"
echo "Info: JIRA Ticket: $jira_ticket"

local branch_name_parts=()
if [[ -n "$category" ]]; then
  branch_name_parts+=("$category")
fi

local core_branch_name="$sanitized_title"
if [[ -n "$jira_ticket" ]]; then
  core_branch_name="$jira_ticket-${core_branch_name}"
fi
branch_name_parts+=("$core_branch_name")

# Join parts with '/'
branchName="${(j:/:)branch_name_parts}"

if [[ -z "$branchName" ]]; then
    echo "Error: Could not determine a valid branch name from the title." >&2
    exit 1
fi
echo "Info: Creating branch: $branchName"

# --- Git Operations ---
echo "Info: Stashing any current changes..."
git stash || { echo "Error: git stash failed." >&2; exit 1; }

echo "Info: Switching to '$GIT_DEFAULT_BRANCH' branch..."
git switch "$GIT_DEFAULT_BRANCH" || { echo "Error: git switch $GIT_DEFAULT_BRANCH failed." >&2; exit 1; }

local actual_base_branch_for_pr
actual_base_branch_for_pr=$(git rev-parse --abbrev-ref HEAD)

if [[ -z "$actual_base_branch_for_pr" || "$actual_base_branch_for_pr" == "HEAD" ]]; then
  echo "Error: Could not determine the canonical name of the base branch from '$GIT_DEFAULT_BRANCH'." >&2
  exit 1
fi
echo "Info: '$GIT_DEFAULT_BRANCH' resolved to actual branch '$actual_base_branch_for_pr'. This will be the PR target base."

echo "Info: Pulling latest changes for '$GIT_DEFAULT_BRANCH'..."
git pull || { echo "Error: git pull on $GIT_DEFAULT_BRANCH failed." >&2; exit 1; }

echo "Info: Creating and checking out new branch '$branchName'..."
git checkout -b "$branchName" || { echo "Error: git checkout -b $branchName failed." >&2; exit 1; }

echo "Info: Applying stashed changes..."
git stash apply || { echo "Error: 'git stash apply' failed. Please resolve conflicts or issues manually and try again." >&2; exit 1; }

echo "Info: Adding all changes..."
git add . || { echo "Error: git add . failed." >&2; exit 1; }

echo "Info: Committing with message: \"$title\"..."
git commit -m "$title" || { echo "Error: git commit failed." >&2; exit 1; }

echo "Info: Pushing branch '$branchName' to origin..."
git push --set-upstream origin "$branchName" || { echo "Error: git push failed." >&2; exit 1; }

# --- Create Merge/Pull Request ---
mr_description="$title" # Start with the title as the base description

if [[ -n "$jira_ticket" ]]; then
  if [[ -n "$JIRA_BASE_URL" ]]; then
    mr_description="$mr_description\n\n[Jira Ticket]($JIRA_BASE_URL/$jira_ticket)"
    echo "Info: JIRA link will be added to the description using JIRA_BASE_URL."
  else
    echo "Warning: A JIRA ticket ('$jira_ticket') was provided, but the JIRA_BASE_URL environment variable is not set." >&2
    echo "         The JIRA link will NOT be added to the merge/pull request description." >&2
  fi
fi

echo "Info: Creating Merge/Pull Request on $platform..."
case "$platform" in
  gitlab)
    if ! command -v glab &> /dev/null; then
        echo "Error: glab command not found. Please install it or choose a different platform." >&2
        exit 1
    fi
    echo "Executing: glab mr create -t \"$title\" -d \"$mr_description\" --source-branch \"$branchName\" --target-branch \"$GIT_DEFAULT_BRANCH\""
    glab mr create -t "$title" -d "$mr_description" --source-branch "$branchName" --target-branch "$GIT_DEFAULT_BRANCH" || { echo "Error: glab mr create failed." >&2; exit 1; }
    ;;
  github)
    if ! command -v gh &> /dev/null; then
        echo "Error: gh command not found. Please install it or choose a different platform." >&2
        exit 1
    fi
    echo "Executing: gh pr create --title \"$title\" --body \"$mr_description\" --head \"$branchName\" --base \"$GIT_DEFAULT_BRANCH\""
    gh pr create --title "$title" --body "$mr_description" --head "$branchName" --base "$GIT_DEFAULT_BRANCH" || { echo "Error: gh pr create failed." >&2; exit 1; }
    ;;
esac

echo "Info: Successfully created branch and merge/pull request."