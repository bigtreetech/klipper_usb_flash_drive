#!/bin/bash
color_end='\033[0m'
color_red='\033[31m'
color_green='\033[32m'
color_yellow='\033[33m'

prevent_sudo_execution() {
    if [[ -n "${SUDO_USER}" ]]; then
        echo -e "${color_red}[0]:Cannot install with sudo (root) privileges${color_end}"
        exit 1
    fi
    if [[ $(id -u) -ne 0 ]] && [[ $(id -ru) -eq 0 ]]; then
        echo -e "${color_red}[1]:Cannot install with sudo (root) privileges${color_end}"
        exit 1
    fi
    if [[ "$(whoami)" == "root" ]]; then
        echo -e "${color_red}[2]:Cannot install with sudo (root) privileges${color_end}"
        exit 1
    fi
}

prevent_sudo_execution

sudo cp ./usb_udev.sh /boot/scripts
sudo cp ./15-udev.rules /etc/udev/rules.d
sudo cp ./usb-mount@.service /etc/systemd/system/

sudo sed -i 's/%user%/'''`whoami`'''/' /boot/scripts/usb_udev.sh

if [ `grep -c "PrivateMounts=yes" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '1' ];then
    sudo sed -i 's/PrivateMounts=yes/PrivateMounts=no/' /usr/lib/systemd/system/systemd-udevd.service
elif [ `grep -c "PrivateMounts=no" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '0' ];then
    sudo bash -c 'echo "PrivateMounts=no" >> /usr/lib/systemd/system/systemd-udevd.service'
fi

if [ `grep -c "MountFlags=shared" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '1' ];then
    sudo bash -c 'echo "MountFlags=shared" >> /usr/lib/systemd/system/systemd-udevd.service'
fi

sync
sudo systemctl daemon-reload
sudo service systemd-udevd --full-restart

echo -e "${color_green}Auto-mounting of USB Flash Drive has been installed!${color_end}"
