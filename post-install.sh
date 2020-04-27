#! /bin/bash

# Arch Linux Installation Package.
echo "Arch Configurator"

# Disk variable
disk=vda

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
useradd -m -g users -G wheel,power,input,storage,network -s /bin/bash juan
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user juan"
passwd juan

# Install bootloader
pacman -S grub efibootmgr --noconfirm
mkdir /boot/efi
mount /dev/${disk}1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install xfce
pacman -S xfce4 xfce4-goodies xfce4-taskmanager xfce4-whiskermenu-plugin lightdm lightdm-gtk-greeter \
lightdm-gtk-greeter-settings xorg xorg-xinit xorg-server archlinux-wallpaper variety screenfetch breeze-gtk kde-gtk-config \
plank user-manager --noconfirm
echo "exec startxfce4" > ~/.xinitrc
systemctl enable lightdm

# Install sound
pacman -S pulseaudio pulseaudio-alsa pavucontrol alsa-firmware alsa-lib alsa-plugins alsa-utils gstreamer gst-plugins-good \
gst-plugins-bad gst-plugins-base gst-plugins-ugly playerctl volumeicon --noconfirm

# Install system support
pacman -S networkmanager network-manager-applet nvidia-lts nvidia xf86-video-amdgpu wget curl git gvfs gvfs-smb sshfs \
smbclient gparted gnome-disk-utility htop kdeconnect openssh pamac-aur ark --noconfirm

# Install vm support
pacman -S qemu-guest-agent virtualbox-guest-utils --noconfirm

# Install printer support
pacman -S system-config-printer cups-pdf cups-pk-helper print-manager --noconfirm

# Install office
pacman -S libreoffice-fresh libreoffice-fresh-en-gb libreoffice-fresh-es libmythes mythes-en mythes-es hunspell \
hunspell-en_GB hunspell-es_co thunderbird --noconfirm

# Install fonts
pacman -S awesome-terminal-fonts adobe-source-sans-pro-fonts cantarell-fonts noto-fonts ttf-bitstream-vera ttf-dejavu \
ttf-droid ttf-hack ttf-inconsolata ttf-liberation ttf-roboto ttf-ubuntu-font-family tamsyn-font --noconfirm

# Install media
pacman -S gwenview vlc gimp --noconfirm

# Remove libreoffice logo
sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc

# Auto-start screenfetch in terminal
echo 'screenfetch' >> /home/juan/.bashrc

# Uncoment to mount unraid share
echo 'documents /home/juan/Documents 9p trans=virtio,version=9p2000.L,_netdev,rw 0 0' >> /etc/fstab

# Install swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Enable services
systemctl enable NetworkManager.service
systemctl enable sshd.service
systemctl enable org.cups.cupsd.service

# Install icons - https://github.com/erikdubois/ArchXfce4
cd /home/juan
git clone https://github.com/erikdubois/ArchXfce4.git
cd ArchXcfe4/installation
./300-install-themes-icons-cursors-conky-v1.sh

echo "Configuration done. You can now exit chroot."
