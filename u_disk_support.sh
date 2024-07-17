#!/bin/bash

sudo cp ./usb_udev.sh /boot/scripts
sudo cp ./15-udev.rules /etc/udev/rules.d

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

echo "Auto-mounting of u-disk is enabled!"
