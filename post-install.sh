#! /bin/bash

# Arch Linux Installation Package.
echo "Arch Configurator"

# Disk variable
disk=vda

# Uncoment to mount unraid share
echo 'documents /home/juan/Documents 9p trans=virtio,version=9p2000.L,_netdev,rw 0 0' >> /etc/fstab

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

# Create new user
useradd -m -g users -G wheel,power,iput,storage,network -s /bin/bash juan
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user juan"
passwd juan

# Install additional packages
pacman -S openssh grub efibootmgr networkmanager pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server git nvidia-lts \
nvidia xf86-video-amdgpu wget curl --noconfirm

# Install bootloader
mkdir /boot/efi
mount /dev/${disk}1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager.service

# Enable ssh
systemctl enable sshd.service

# Install yay & pamac
cd /home/juan
git clone https://aur.archlinux.org/yay.git && chmod -R 777 yay && cd yay
# makepkg -si --noconfirm && yay -S pamac-aur --noconfirm

# Install xfce
pacman -S xfce4 lightdm lightdm-gtk-greeter gvfs gvfs-smb sshfs system-config-printer cups-pdf cups-pk-helper print-manager \
smbclient variety screenfetch chromium breeze-gtk kde-gtk-config ark libreoffice-fresh libreoffice-fresh-en-gb \
libreoffice-fresh-es gwenview vlc gimp network-manager-applet libmythes mythes-en mythes-es ttf-liberation hunspell \
hunspell-en_GB hunspell-es_co adobe-source-sans-pro-fonts  thunderbird user-manager kdeconnect sddm gparted htop \
xfce4-taskmanager gnome-disk-utility lightdm-gtk-greeter-settings xfce4-whiskermenu-plugin plank --noconfirm

# Install icons - https://github.com/erikdubois/ArchXfce4
wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/300-install-themes-icons-cursors-conky-v1.sh
./300-install-themes-icons-cursors-conky-v1.sh

echo "exec startxfce4" > ~/.xinitrc
systemctl enable lightdm
systemctl enable org.cups.cupsd.service

# Remove libreoffice logo
sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc

# Auto-start screenfetch in terminal
echo 'screenfetch' >> /home/juan/.bashrc

echo "Configuration done. You can now exit chroot."
