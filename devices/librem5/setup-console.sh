#!/bin/sh

set -e

#Set a bigger font for the console (will try to move it to mobian-tweaks-common or similar)
sed -i -e 's/^FONTFACE=.*$/FONTFACE="Terminus"/' -e 's/^FONTSIZE=.*$/FONTSIZE="12x24"/'  /etc/default/console-setup

#Activate suspend when the power button is pressed
# edit the line in the conf file who has the HandlePowerKey
sed -i -e "s/^HandlePowerKey=.*$/HandlePowerKey=suspend/"  /etc/systemd/logind.conf.d/*.conf

#Set a bigger font for early boot messages; rotate framebuffer console to landscape mode
# Look for " rw " to find the kernel parameters line.
# The conf file is provided by the -tweaks packages (but not for all devices)
sed -i -e "s/ rw / rw fbcon=rotate:1,font:TER16x32 /"  /etc/u-boot-menu.d/*.conf

