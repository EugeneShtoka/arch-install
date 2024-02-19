
#!/bin/bash

# Function to check if the vault is locked
check_vault_status() {
  bw status | grep -q 'status: locked'
  return $?  # Return 0 if locked, 1 if unlocked
}

# Check initial vault status
check_vault_status
if [[ $? -eq 0 ]]; then
    export BW_SESSION=$(bw unlock | grep '$ export' | awk -F'BW_SESSION=' '{print $2}')
else
    echo "Bitwarden vault is already unlocked."
fi