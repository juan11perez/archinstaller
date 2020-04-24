#! /bin/bash

# This is Configuration script of Krushn's Arch Linux Installation Package.
# Visit krushndayshmookh.github.io/krushn-arch for instructions.

echo "Arch Configurator"

# Install swap file
fallocate -l 3G /swapfile
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
echo "127.0.1.1 dayshmookh.localdomain archlinux" >> /etc/hosts

# Generate initramfs
mkinitcpio -P

# Set root password
passwd

# Install additional packages
pacman -S openssh grub efibootmgr networkmanager pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server --noconfirm

# Install bootloader
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
grub-mkconfig -o /boot/grub/grub.cfg
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
# grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
useradd -m -g users -G wheel -s /bin/bash juan
# useradd -m -G wheel,power,iput,storage,uucp,network -s /usr/bin/zsh krushn
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user juan"
passwd juan

# Setup display manager
# systemctl enable sddm.service

# Enable services
systemctl enable NetworkManager.service

# Enable ssh
systemctl enable sshd.service

echo "Configuration done. You can now exit chroot."
