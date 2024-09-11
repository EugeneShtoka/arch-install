# systemctl --user enable battery-alert.service
# systemctl --user start battery-alert.service
# systemctl --user enable battery-alert.timer
# systemctl --user start battery-alert.timer

# # Create rule to auto-hook monitors on connect
# RULE_FILE="/etc/udev/rules.d/11-monitor.rules"
# CONTENT="SUBSYSTEM==\"drm\", ACTION==\"add\", RUN+=\"/home/eugene/.scripts/monitor-setup-hook.sh multi\"\nSUBSYSTEM==\"drm\", ACTION==\"remove\", RUN+=\"/home/eugene/.scripts/monitor-setup-hook.sh single\""

# echo -e "$CONTENT" | sudo tee "$RULE_FILE" > /dev/null

RULE_FILE="/etc/udev/rules.d/12-charger.rules"
CONTENT="SUBSYSTEM==\"power_supply\", ATTR{online}==\"1\", RUN+=\"/home/eugene/.scripts/charger-connected.sh\""

echo -e "$CONTENT" | sudo tee "$RULE_FILE" > /dev/null

# Reload udev rules to apply the changes
sudo udevadm control --reload-rules && udevadm trigger
