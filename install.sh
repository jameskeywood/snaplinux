#!/bin/bash

# Snap Linux installer
# James Keywood - 01/Apr/2020

# pre-installation
clear
echo -e "Pre-installation\n"
read -n 1 -s -r -p "Press any key to continue"

# set the keyboard layout
clear
echo -e "Set the keyboard layout\n"
echo "Keyboard layouts:"
ls /usr/share/kbd/keymaps/**/*.map.gz
read -p "Enter a keyboard layout: " layout
loadkeys $layout
echo -e "Keyboard layout set to $layout\n"
read -n 1 -s -r -p "Press any key to continue"

# verify the boot mode
clear
echo -e "Verify the boot mode\n"
dir="/sys/firmware/efi/efivars"
if [ -d "$dir" ]
then
  echo -e "UEFI boot mode\n"
  uefi=true
else
  echo -e "Legacy boot mode\n"
fi
read -n 1 -s -r -p "Press any key to continue"

# wireless or wired network
clear
echo -e "Wireless or wired network\n"
ip link | grep ether > network.txt
[ -s network.txt ]
if [ $?=0 ]
then
  echo -e "Wired network detected\n"
else
  echo -e "Wireless network detected\n"
  echo -e "Configure wireless network"
  read -n 1 -s -r -p "Press any key to continue"
  wifi-menu
fi
read -n 1 -s -r -p "Press any key to continue"

# connect to the internet
clear
echo -e "Connect to the internet\n"
echo "Network interfaces:"
ip link
echo -e "\nTesting network"
timeout 10s ping archlinux.org > ping.txt
[ -s ping.txt ]
if [ $?=0 ]
then
  echo -e "Network connection success\n"
else
  echo -e "Network connection failure\n"
  exit 1
fi
read -n 1 -s -r -p "Press any key to continue"

# update the system clock
clear
echo -e "Update the system clock\n"
timedatectl set-ntp true
echo "Status:"
timedatectl status
echo -e "\nSystem clock set"
read -n 1 -s -r -p "Press any key to continue"

# partition the disks
clear
echo -e "Partition the disks\n"
if [[ $uefi = true ]]
then
  echo "UEFI with GPT"
  echo "/dev/sda1 EFI system partition (260-512 MiB)"
  echo "/dev/sda2 Linux x86-64 root (Remainder of device)"
  echo "/dev/sda3 Linux swap (More than 512 MiB)"
else
  echo "BIOS with MBR"
  echo "/dev/sda1 Linux (Remainder of the device) (Bootable)"
  echo "/dev/sda2 Linux swap (More than 512 MiB)"
fi
read -n 1 -s -r -p "Press any key to continue"
cfdisk /dev/sda
echo -e "\nDisk partitioned successfully"
read -n 1 -s -r -p "Press any key to continue"

# format the partitions
clear
echo -e "Format the partitions\n"
if [[ $uefi = true ]]
then
  mkfs.ext4 /dev/sda2
  mkswap /dev/sda3
  swapon /dev/sda3
else
  mkfs.ext4 /dev/sda1
  mkswap /dev/sda2
  swapon /dev/sda2
fi
echo -e "\nFile system formatted successfully"
read -n 1 -s -r -p "Press any key to continue"

# mount the file systems
clear
echo -e "Mount the file systems\n"
if [[ $uefi = true ]]
then
  mount /dev/sda1 /mnt/efi
  mount /dev/sda2 /mnt
else
  mount /dev/sda1 /mnt
fi
echo "File system mounted successfully"
read -n 1 -s -r -p "Press any key to continue"

# installation
clear
echo -e "Installation\n"
read -n 1 -s -r -p "Press any key to continue"

# select mirrors
clear
echo -e "Select mirrors\n"
echo "Sort mirrors to the necessary order"
read -n 1 -s -r -p "Press any key to continue"
nano /etc/pacman.d/mirrorlist
echo "Mirrors configured"
read -n 1 -s -r -p "Press any key to continue"

# install essential packages
clear
echo -e "Install essential packages\n"
echo "Installing now"
pacstrap /mnt base linux linux-firmware nano dhcpcd
echo -e "\nPackages installed"
read -n 1 -s -r -p "Press any key to continue"

# configure the system
clear
echo -e "Configure the system\n"
read -n 1 -s -r -p "Press any key to continue"

# fstab
clear
echo -e "Fstab\n"
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "Complete"
read -n 1 -s -r -p "Press any key to continue"

# chroot
clear
echo -e "Chroot\n"
cp configure.sh /mnt
read -n 1 -s -r -p "Press any key to continue"
arch-chroot /mnt ./configure.sh

# moves on to configuration.sh script
# after the script, this script is returned to

# cleanup
clear
echo -e "Cleanup\n"
rm /mnt/configure.sh
read -n 1 -s -r -p "Press any key to continue"

# reboot
clear
echo -e "Reboot\n"
echo -e "Installation complete"
read -n 1 -s -r -p "Press any key to continue"
reboot
