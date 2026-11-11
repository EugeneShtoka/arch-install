#!/bin/zsh
# Unlock the gnome-keyring login keyring from a terminal (no GUI prompter needed),
# then restart kithd so it picks up its secrets. No-op when already unlocked.

keyring_locked() {
    busctl --user call org.freedesktop.secrets /org/freedesktop/secrets/aliases/default \
        org.freedesktop.DBus.Properties Get ss org.freedesktop.Secret.Collection Locked \
        2>/dev/null | grep -q 'true'
}

keyring_locked || exit 0

for attempt in 1 2 3; do
    read -rs "password?Keyring is locked. Password (empty to skip): " || exit 1
    echo
    [[ -z "$password" ]] && exit 1
    print -rn -- "$password" | gnome-keyring-daemon --unlock >/dev/null 2>&1
    unset password
    if ! keyring_locked; then
        echo "Keyring unlocked, restarting kithd"
        systemctl --user restart kithd.service
        exit 0
    fi
    echo "Wrong password"
done
exit 1
