#!/bin/sh

# Setup hostname
echo $1 > /etc/hostname

# Change plymouth default theme
plymouth-set-default-theme mobian

# Load phosh on startup if package is installed
if [ -f /usr/bin/phosh ]; then
    systemctl enable phosh.service
fi

# systemd-firstboot requires user input, which isn't possible
# on mobile devices
systemctl disable systemd-firstboot.service
systemctl mask systemd-firstboot.service
