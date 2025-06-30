#!/bin/bash

MNT_PATH=/home/%user%/printer_data/gcodes/         # mount folder
DEV_PRE=$1
DEV_NAME=$2
DEV_ACTION=$3
DEV_PATH=/dev/$DEV_NAME
GCODE_PATH=$MNT_PATH$DEV_PRE-$DEV_NAME
USER_UID=$(id -u %user%)
USER_GID=$(id -g %user%)

if [ $DEV_ACTION == "add" ]; then
    if [[ ! -b $DEV_PATH ]]; then
        exit 1
    fi
    FS_TYPE=$(blkid -s TYPE -o value "$DEV_PATH" 2>/dev/null)
    if [[ -z "$FS_TYPE" ]]; then
        exit 1
    fi
    if grep -qs "$DEV_PATH" /proc/mounts; then
        exit 1
    fi
    sudo mkdir -p $GCODE_PATH
    sudo mount -o iocharset=utf8,uid=$USER_UID,gid=$USER_GID,umask=0022 $DEV_PATH $GCODE_PATH
    if [[ $? -ne 0 ]]; then
        sudo rmdir $GCODE_PATH
        exit 1
    fi
elif [ $DEV_ACTION == "remove" ]; then
    if grep -qs "$GCODE_PATH" /proc/mounts; then
        sudo umount $GCODE_PATH
    fi
    if [[ -e  $GCODE_PATH ]] ; then
        /usr/bin/rmdir  $GCODE_PATH
    fi
fi

exit 0
