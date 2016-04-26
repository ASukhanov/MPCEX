#!/bin/bash
# mount usb drive with user access

sudo umount /mnt/disk1
sudo mount -o uid=pi,gid=pi /mnt/disk1
sudo umount /mnt/disk2
sudo mount -o uid=pi,gid=pi /mnt/disk2
