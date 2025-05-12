#!/bin/zsh

# Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "Warning: This is not a Git repository." >&2
  exit 1
fi

# Get the URL of the 'origin' remote
remote_url=$(git remote get-url origin 2>/dev/null)
exit_status=$?

if [[ $exit_status -ne 0 || -z "$remote_url" ]]; then
  remotes=$(git remote 2>/dev/null)
  if [[ -z "$remotes" ]]; then
    echo "Warning: This Git repository has no remotes configured." >&2
    exit 1
  else
    first_remote=$(echo "$remotes" | head -n1)
    remote_url=$(git remote get-url "$first_remote" 2>/dev/null)
    if [[ -z "$remote_url" ]]; then
        echo "Warning: Could not retrieve a valid remote URL for remote '$first_remote'." >&2
        exit 1
    else
        echo "Info: No 'origin' remote found. Using remote '$first_remote' instead: $remote_url"
    fi
  fi
fi

# 4. Parse the remote URL to construct a browseable HTTPS URL
web_url=""
hostname=""

# Remove .git suffix first
parsed_url="${remote_url%.git}"

if [[ "$parsed_url" == git@* ]]; then
  temp_url="${parsed_url#git@}"
  hostname="${temp_url%%:*}"
  git_path="${temp_url#*:}"
  web_url="https://$hostname/$git_path"
elif [[ "$parsed_url" == http://* || "$parsed_url" == https://* ]]; then
  web_url="$parsed_url"
  hostname=$(echo "$web_url" | sed -E 's#^https?://([^/]+)/.*#\1#')
else
  echo "Warning: Unrecognized remote URL format: $remote_url" >&2
  exit 1
fi

# Check if it's a known GitHub or GitLab URL
if [[ "$hostname" == *github.com* || "$hostname" == *gitlab.com* ]]; then
  echo "Info: Opening repository page: $web_url"
else
  echo "Warning: The remote URL does not point to a recognized GitHub or GitLab domain." >&2
  echo "Remote URL was: $remote_url" >&2
  echo "Parsed web URL: $web_url" >&2
  exit 1
fi

# Open the URL in the default browser
if command -v xdg-open &> /dev/null; then
  setsid $BROWSER "$web_url" >/dev/null 2>&1
else
  echo "Error: 'xdg-open' command not found. Please install xdg-utils." >&2
  echo "Please open this URL manually: $web_url" >&2
  exit 1
fi

exit 0