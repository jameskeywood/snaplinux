#!/bin/bash

# Snap Linux installer
# James Keywood - 01/Apr/2020

# time zone
clear
echo -e "Time zone\n"
echo "Regions:"
ls /usr/share/zoneinfo
read -p "Enter a region: " region
echo -e "\n Cities:"
ls /usr/share/zoneinfo/$region
read -p "Enter a city: " city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc
echo -e "\nTime zone set"
read -n 1 -s -r -p "Press any key to continue"

# localisation
clear
echo -e "Localisation\n"
echo "Uncomment needed locales if necessary"
read -n 1 -s -r -p "Press any key to continue"
nano /etc/locale.gen
locale-gen
read -p "Enter the desired locale: " locale
touch /etc/locale.conf
echo "LANG=$locale" > /etc/locale.conf
touch /etc/vconsole.conf
echo "KEYMAP=$layout" > /etc/vconsole.conf
echo -e "\nLocalisation complete"
read -n 1 -s -r -p "Press any key to continue"

# network configuration
clear
echo -e "Network configuration\n"
read -p "Enter a hostname: " hostname
touch /etc/hostname
echo "$hostname" > /etc/hostname
touch /etc/hosts
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t$hostname.localdomain\t$hostname" >> /etc/hosts
read -n 1 -s -r -p "Press any key to continue"

# root password
clear
echo -e "Root password\n"
passwd
read -n 1 -s -r -p "Press any key to continue"

# boot loader
clear
echo -e "Boot loader\n"
pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
read -n 1 -s -r -p "Press any key to continue"

# enable dhcpcd
clear
echo -e "Enable DHCPCD\n"
systemctl enable dhcpcd
read -n 1 -s -r -p "Press any key to continue"

# exit
clear
echo -e "Exit\n"
echo "Configuration complete"
read -n 1 -s -r -p "Press any key to continue"
exit
