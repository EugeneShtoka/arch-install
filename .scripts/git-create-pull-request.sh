#!/bin/zsh

# Default values for optional parameters
local jira_ticket=""
local category=""
local platform="github"
local title=""

fetch_jira_ticket_summary() {
  local issue_key="$1"
  local jira_summary_val="" # Renamed to avoid conflict with global

  # Check for necessary JIRA environment variables
  if [[ -z "$JIRA_BASE_URL" ]]; then
    echo "Error: JIRA_BASE_URL environment variable is not set. Cannot fetch JIRA ticket summary." >&2
    return 1
  fi
  if [[ -z "$JIRA_USER_EMAIL" ]]; then
    echo "Error: JIRA_USER_EMAIL environment variable is not set. Cannot fetch JIRA ticket summary." >&2
    return 1
  fi
  if [[ -z "$JIRA_API_TOKEN" ]]; then
    echo "Error: JIRA_API_TOKEN environment variable is not set. Cannot fetch JIRA ticket summary." >&2
    return 1
  fi

  # Ensure JIRA_BASE_URL does not end with a slash for robust concatenation
  local clean_jira_base_url="${JIRA_BASE_URL%/}"
  # Using JIRA Cloud API v3 endpoint. For JIRA Server, this might be /rest/api/2/
  local api_url="$clean_jira_base_url/rest/api/3/issue/$issue_key?fields=summary"

  echo "Info: Fetching summary from JIRA API: $api_url" >&2

  local http_response
  http_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
    -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$api_url")

  local http_status=$(echo "$http_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  local response_body=$(echo "$http_response" | sed -e 's/HTTPSTATUS:.*//')

  if [[ "$http_status" -ne 200 ]]; then
    echo "Error: JIRA API request failed with status $http_status for issue '$issue_key'." >&2
    echo "Response (first 500 chars): $(echo "$response_body" | head -c 500)" >&2 # Avoid overly verbose output
    return 1
  fi

  jira_summary_val=$(echo "$response_body" | jq -r '.fields.summary')

  if [[ -z "$jira_summary_val" || "$jira_summary_val" == "null" ]]; then
    echo "Error: Could not parse summary from JIRA response, or summary is empty/null for issue '$issue_key'." >&2
    echo "Response Body (first 500 chars): $(echo "$response_body" | head -c 500)" >&2
    return 1
  fi

  echo "$jira_summary_val" # Output the summary to be captured by command substitution
  return 0 # Success
}

if [[ -z "$GIT_DEFAULT_BRANCH" ]]; then
  echo "Error: GIT_DEFAULT_BRANCH environment variable is not set."
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
    -*)
      echo "Unknown option: $arg" >&2;
      usage ;;
    *) # Positional argument (part of title)
      args_for_title+=("$arg") ;;
  esac
done

# --- Validate Mandatory Parameters ---
if [[ ${#args_for_title[@]} -gt 0 ]]; then
  title="${args_for_title[*]}" # Joins with space by default with [*]
else
 if [[ -n "$jira_ticket" ]]; then
    echo "Info: Title not provided directly. Attempting to fetch from JIRA ticket '$jira_ticket'..."
    if ! command -v curl &>/dev/null; then echo "Error: curl is required to fetch JIRA title." >&2; exit 1; fi
    if ! command -v jq &>/dev/null; then echo "Error: jq is required to parse JIRA title." >&2; exit 1; fi

    local fetched_jira_title
    fetched_jira_title=$(fetch_jira_ticket_summary "$jira_ticket") # Errors/info echoed from function

    if [[ $? -eq 0 && -n "$fetched_jira_title" ]]; then # $? is the return status of fetch_jira_ticket_summary
      title="$fetched_jira_title"
      echo "Info: Using JIRA ticket summary as title: \"$title\""
    else
      echo "Error: Failed to obtain a valid title from JIRA ticket '$jira_ticket'." >&2
      echo "Please check JIRA details, environment variables, and network access, or provide a title manually." >&2
      exit 1
    fi
  else
    echo "Error: Title is mandatory. Provide it as positional arguments or specify a --jira-ticket to fetch its summary." >&2
    usage
  fi
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