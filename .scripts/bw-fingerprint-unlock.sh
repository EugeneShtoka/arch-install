#!/bin/bash

# Bitwarden Fingerprint Unlock Script
# Uses fingerprint authentication to unlock Bitwarden vault

set -e

# Configuration
KEYRING_SERVICE="bitwarden"
KEYRING_USER="$(whoami)"
BW_SESSION_FILE="$HOME/.config/bw-session"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if secret-tool is available
check_dependencies() {
    if ! command -v secret-tool &> /dev/null; then
        log_error "secret-tool is not installed. Please install libsecret-tools:"
        log_error "sudo pacman -S libsecret"
        exit 1
    fi

    if ! command -v bw &> /dev/null; then
        log_error "Bitwarden CLI is not installed"
        exit 1
    fi

    if ! command -v fprintd-verify &> /dev/null; then
        log_error "fprintd-verify is not available. Please install fprintd"
        exit 1
    fi
}

# Function to authenticate with fingerprint
authenticate_fingerprint() {
    log_info "Place your finger on the fingerprint reader..."
    if fprintd-verify "$USER" 2>/dev/null; then
        log_info "Fingerprint authentication successful"
        return 0
    else
        log_error "Fingerprint authentication failed"
        return 1
    fi
}

# Function to store master password (one-time setup)
store_master_password() {
    log_info "Setting up fingerprint unlock for Bitwarden..."
    log_info "You'll need to enter your master password once to store it securely."

    read -s -p "Enter your Bitwarden master password: " master_password
    echo

    # Authenticate with fingerprint to confirm setup
    log_info "Authenticate with fingerprint to confirm setup:"
    if ! authenticate_fingerprint; then
        log_error "Setup cancelled - fingerprint authentication required"
        exit 1
    fi

    # Store password in keyring
    echo "$master_password" | secret-tool store --label="Bitwarden Master Password" service "$KEYRING_SERVICE" username "$KEYRING_USER"

    if [ $? -eq 0 ]; then
        log_info "Master password stored securely in keyring"
        log_info "Setup complete! You can now use fingerprint to unlock Bitwarden"
    else
        log_error "Failed to store password in keyring"
        exit 1
    fi

    # Clear password from memory
    unset master_password
}

# Function to retrieve master password from keyring
get_master_password() {
    secret-tool lookup service "$KEYRING_SERVICE" username "$KEYRING_USER" 2>/dev/null
}

# Function to unlock Bitwarden
unlock_bitwarden() {
    # Check if already unlocked
    bw_status=$(bw status | jq -r '.status' 2>/dev/null)
    if [[ "$bw_status" == "unlocked" ]]; then
        log_info "Bitwarden is already unlocked"
        return 0
    fi

    # Authenticate with fingerprint
    if ! authenticate_fingerprint; then
        log_error "Cannot unlock Bitwarden without fingerprint authentication"
        return 1
    fi

    # Get master password from keyring
    master_password=$(get_master_password)
    if [ -z "$master_password" ]; then
        log_error "Master password not found in keyring. Run with --setup first."
        return 1
    fi

    log_info "Unlocking Bitwarden vault..."

    # Unlock Bitwarden and capture session key
    BW_SESSION=$(echo "$master_password" | bw unlock --raw 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$BW_SESSION" ]; then
        # Export session for current shell
        export BW_SESSION

        # Save session to file for other scripts
        echo "export BW_SESSION=$BW_SESSION" > "$BW_SESSION_FILE"

        log_info "Bitwarden unlocked successfully"
        log_info "Session exported to BW_SESSION variable"
        log_info "To use in other terminals: source $BW_SESSION_FILE"
        return 0
    else
        log_error "Failed to unlock Bitwarden vault"
        return 1
    fi

    # Clear password from memory
    unset master_password
}

# Function to remove stored password
remove_stored_password() {
    log_info "Removing stored Bitwarden master password..."

    if authenticate_fingerprint; then
        secret-tool clear service "$KEYRING_SERVICE" username "$KEYRING_USER"
        log_info "Stored password removed from keyring"
    else
        log_error "Fingerprint authentication required to remove stored password"
        exit 1
    fi
}

# Main function
main() {
    check_dependencies

    case "${1:-}" in
        "--setup")
            store_master_password
            ;;
        "--remove")
            remove_stored_password
            ;;
        "--help"|"-h")
            echo "Usage: $0 [--setup|--remove|--help]"
            echo ""
            echo "  --setup    Store master password for fingerprint unlock (one-time)"
            echo "  --remove   Remove stored master password from keyring"
            echo "  --help     Show this help message"
            echo ""
            echo "Run without arguments to unlock Bitwarden with fingerprint"
            ;;
        "")
            unlock_bitwarden
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

main "$@"