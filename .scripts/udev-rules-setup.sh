#!/bin/zsh

write_rule() {
    local file=$1
    local content=$2
    echo -e "$content" | sudo tee "/etc/udev/rules.d/$file" >/dev/null
}

write_rule "10-monitor.rules" \
    "SUBSYSTEM==\"drm\", ACTION==\"change\", RUN+=\"$SCRIPTS_PATH/monitor-setup-hook.sh\""

write_rule "12-charger.rules" \
    "SUBSYSTEM==\"power_supply\", ATTR{online}==\"1\", RUN+=\"$SCRIPTS_PATH/charger-connected.sh\"\nSUBSYSTEM==\"power_supply\", ATTR{online}==\"0\", RUN+=\"$SCRIPTS_PATH/charger-disconnected.sh\""

write_rule "20-pcspkr-beep.rules" \
    "SUBSYSTEM==\"input\", ACTION==\"add\", ATTRS{name}==\"PC Speaker\", ENV{DEVNAME}!=\"\", GROUP=\"beep\", MODE=\"0620\""

write_rule "50-bluetooth-power.rules" \
    "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"8087\", ATTR{idProduct}==\"0033\", ATTR{power/control}=\"on\""

write_rule "50-zmk.rules" \
    "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"1d50\", ATTRS{idProduct}==\"615e\", MODE=\"0666\", TAG+=\"uaccess\""

write_rule "80-battery-charge-threshold.rules" \
    "ACTION==\"add\", SUBSYSTEM==\"power_supply\", KERNEL==\"BAT0\", ATTR{charge_control_end_threshold}=\"80\""

sudo udevadm control --reload
