#! /bin/bash

# This is Arch Linux Installation Package.

echo "Arch Configurator"

# Disk variable
disk=vda

# Install swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Set date time
ln -sf /usr/share/zoneinfo/Asia/Dubai /etc/localtime
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/en_GB.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf

# Set hostname
echo "archlinux" >> /etc/hostname
echo "127.0.1.1 localhost.localdomain archlinux" >> /etc/hosts

# Generate initramfs
mkinitcpio -P

# Set root password
passwd

# Install additional packages
pacman -S openssh grub efibootmgr networkmanager pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server git --noconfirm

# Install bootloader
mkdir /boot/efi
mount /dev/${disk}1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
useradd -m -g users -G wheel -s /bin/bash juan
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user juan"
passwd juan

# Setup display manager
# systemctl enable sddm.service

# Enable services
systemctl enable NetworkManager.service

# Enable ssh
systemctl enable sshd.service

# Install yay
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
# Install pamac
yay -S pamac-aur --noconfirm

echo "Configuration done. You can now exit chroot."
