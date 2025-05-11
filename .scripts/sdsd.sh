#!/bin/zsh

# Script to open the GitHub/GitLab page of the current Git repository.

# 1. Check if 'git' command is available
if ! command -v git &> /dev/null; then
  echo "Error: 'git' command not found. Please install Git." >&2
  exit 1
fi

# 2. Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "Warning: This is not a Git repository." >&2
  exit 1
fi

# 3. Get the URL of the 'origin' remote
remote_url=$(git remote get-url origin 2>/dev/null)
exit_status=$?

if [[ $exit_status -ne 0 || -z "$remote_url" ]]; then
  # Try to see if there are other remotes if 'origin' fails or is not set up
  remotes=$(git remote 2>/dev/null)
  if [[ -z "$remotes" ]]; then
    echo "Warning: This Git repository has no remotes configured." >&2
    exit 1
  else
    # Take the first remote in the list if 'origin' wasn't found
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
  # SSH format: git@hostname:user/repo
  # Remove "git@" prefix
  temp_url="${parsed_url#git@}"
  # Split hostname and path
  hostname="${temp_url%%:*}"
  path="${temp_url#*:}"
  web_url="https://$hostname/$path"
elif [[ "$parsed_url" == http://* || "$parsed_url" == https://* ]]; then
  # HTTP/HTTPS format: https://hostname/user/repo
  web_url="$parsed_url"
  # Extract hostname for checking
  hostname=$(echo "$web_url" | sed -E 's#^https?://([^/]+)/.*#\1#')
else
  echo "Warning: Unrecognized remote URL format: $remote_url" >&2
  exit 1
fi

# 5. Check if it's a known GitHub or GitLab URL
if [[ "$hostname" == *github.com* || "$hostname" == *gitlab.com* ]]; then
  echo "Info: Opening repository page: $web_url"
else
  echo "Warning: The remote URL does not point to a recognized GitHub or GitLab domain." >&2
  echo "Remote URL was: $remote_url" >&2
  echo "Parsed web URL: $web_url" >&2
  # Ask user if they still want to try opening this URL
  if read -q "choice?Do you want to try opening this URL anyway? (y/N): "; then
      echo # newline after read -q
      if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
          echo "Aborted opening."
          exit 0
      fi
  else
      echo # newline if read timed out or failed
      echo "Aborted opening."
      exit 0
  fi
fi


# 6. Open the URL in the default browser
if command -v xdg-open &> /dev/null; then
  xdg-open "$web_url"
elif
  echo "Error: 'xdg-open' command not found. Please install xdg-utils." >&2
  echo "Please open this URL manually: $web_url" >&2
  exit 1
fi

exit 0