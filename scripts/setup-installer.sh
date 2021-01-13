#!/bin/sh

# Setup ondevice installer to start on boot
systemctl enable calamaresfb.service

# Disable eg25-manager (we don't need the modem during install)
systemctl disable eg25-manager.service
