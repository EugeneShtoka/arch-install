#!/bin/zsh

# Default values for optional parameters
local jira_ticket=""
local category=""
local platform="github"
local title=""

if [[ -z "$GIT_WORK_BRANCH" ]]; then
  echo "Error: GIT_WORK_BRANCH environment variable is not set."
  echo "Please set it to your main development branch (e.g., main, master, develop)."
  exit 1
fi

# --- Usage Function ---
usage() {
  echo "Usage: $0 --title \"<Your Title>\" [options]"
  echo "Creates a new git branch, commits changes, and opens a merge/pull request."
  echo "Mandatory:"
  echo "  --title \"<string>\"       The title for the commit and merge request."
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
    -t|--title)
      title="$2"
      shift 2
      ;;
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
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

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
# Sanitize title for branch name: replace spaces with hyphens, remove most non-alphanumeric chars
# Allows letters, numbers, underscore, hyphen, dot. Converts other sequences of special chars to a single hyphen.
sanitized_title=$(echo "$title" | tr '[:space:]' '-' | tr -cs 'a-zA-Z0-9_.-' '-' | sed 's/--\+/-/g' | sed 's/^-//;s/-$//')

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

echo "Info: Switching to '$GIT_WORK_BRANCH' branch..."
git switch "$GIT_WORK_BRANCH" || { echo "Error: git switch $GIT_WORK_BRANCH failed." >&2; exit 1; }

echo "Info: Pulling latest changes for '$GIT_WORK_BRANCH'..."
git pull || { echo "Error: git pull on $GIT_WORK_BRANCH failed." >&2; exit 1; }

echo "Info: Creating and checking out new branch '$branchName'..."
git checkout -b "$branchName" || { echo "Error: git checkout -b $branchName failed." >&2; exit 1; }

echo "Info: Applying stashed changes..."
git stash apply || { echo "Error: 'git stash apply' failed. Please resolve conflicts or issues manually and try again." >&2; exit 1; }
# You might want to consider `git stash pop` or error handling if apply fails.

echo "Info: Adding all changes..."
git add . || { echo "Error: git add . failed." >&2; exit 1; }

echo "Info: Committing with message: \"$title\"..."
git commit -m "$title" || { echo "Error: git commit failed." >&2; exit 1; }

echo "Info: Pushing branch '$branchName' to origin..."
git push --set-upstream origin "$branchName" || { echo "Error: git push failed." >&2; exit 1; }

# --- Create Merge/Pull Request ---
mr_description="$title" # Start with the title as the base description

if [[ -n "$jira_ticket" ]]; then
  # Assuming a generic JIRA URL structure; adjust if yours differs
  # Example: https://your-jira-instance.com/browse/TICKET-ID
  local jira_base_url="${JIRA_BASE_URL:-https://your-jira.example.com/browse}"
  mr_description="$mr_description\n\n[Jira Ticket]($jira_base_url/$jira_ticket)"
fi

echo "Info: Creating Merge/Pull Request on $platform..."
case "$platform" in
  gitlab)
    if ! command -v glab &> /dev/null; then
        echo "Error: glab command not found. Please install it or choose a different platform." >&2
        exit 1
    fi
    echo "Executing: glab mr create -t \"$title\" -d \"$mr_description\" --source-branch \"$branchName\" --target-branch \"$GIT_WORK_BRANCH\""
    glab mr create -t "$title" -d "$mr_description" --source-branch "$branchName" --target-branch "$GIT_WORK_BRANCH" || { echo "Error: glab mr create failed." >&2; exit 1; }
    ;;
  github)
    if ! command -v gh &> /dev/null; then
        echo "Error: gh command not found. Please install it or choose a different platform." >&2
        exit 1
    fi
    echo "Executing: gh pr create --title \"$title\" --body \"$mr_description\" --head \"$branchName\" --base \"$GIT_WORK_BRANCH\""
    gh pr create --title "$title" --body "$mr_description" --head "$branchName" --base "$GIT_WORK_BRANCH" || { echo "Error: gh pr create failed." >&2; exit 1; }
    ;;
esac

echo "Info: Successfully created branch and merge/pull request."