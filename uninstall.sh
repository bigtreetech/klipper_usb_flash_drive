#!/bin/bash
color_end='\033[0m'
color_red='\033[31m'
color_green='\033[32m'
color_yellow='\033[33m'

sudo rm /boot/scripts/usb_udev.sh
sudo rm /etc/udev/rules.d/15-udev.rules
sudo rm /etc/systemd/system//usb-mount@.service

sync
sudo systemctl daemon-reload
sudo service systemd-udevd --full-restart

echo -e "${color_green}Auto-mounting of USB Flash Drive has been uninstalled!${color_end}"
