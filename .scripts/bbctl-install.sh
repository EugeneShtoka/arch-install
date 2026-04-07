#!/bin/zsh

INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/bbctl"

latest=$(gh release view --repo beeper/bridge-manager --json tagName -q '.tagName')
echo "Installing bbctl $latest..."

gh release download --repo beeper/bridge-manager --pattern bbctl-linux-amd64 --dir /tmp --clobber
chmod +x /tmp/bbctl-linux-amd64
mv /tmp/bbctl-linux-amd64 "$BINARY"

echo "bbctl installed: $($BINARY --version)"
