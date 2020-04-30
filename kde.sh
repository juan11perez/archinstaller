#! /bin/bash

# Kde Desktop Installation Script.
echo "kde desktop"

pacman -S plasma-desktop lightdm breeze-gtk breeze-kde4 kde-gtk-config xorg xorg-xinit xorg-server archlinux-wallpaper \
dolphin konsole spectacle yakuake kate --noconfirm
echo "exec startkde" > ~/.xinitrc
sudo systemctl enable lightdm.service -f
