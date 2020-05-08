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

# Install bluetooth
# pacman -S pulseaudio-bluetooth bluez bluez-libs bluez-utils blueberry --noconfirm
# systemctl enable bluetooth.service && systemctl start bluetooth.service && sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf

# Install laptop support
# pacman -S tlp --noconfirm
# systemctl enable tlp.service

# Install sound
pacman -S pulseaudio pulseaudio-alsa pavucontrol alsa-firmware alsa-lib alsa-plugins alsa-utils gstreamer gst-plugins-good \
gst-plugins-bad gst-plugins-base gst-plugins-ugly playerctl volumeicon --noconfirm

# Install system support
pacman -S networkmanager network-manager-applet nvidia-lts nvidia xf86-video-amdgpu wget curl git gvfs gvfs-smb sshfs \
smbclient gparted gnome-disk-utility htop kdeconnect openssh ark screenfetch variety user-manager plank wireguard-lts \
wireguard-tools vsftpd --noconfirm

# Install vm support
pacman -S qemu-guest-agent virtualbox-guest-utils --noconfirm

# Install printer support
pacman -S system-config-printer cups-pdf cups-pk-helper print-manager --noconfirm

# Install office
pacman -S libreoffice-fresh libreoffice-fresh-en-gb libreoffice-fresh-es libmythes mythes-en mythes-es hunspell \
hunspell-en_GB hunspell-es_co thunderbird kate gnome-calculator --noconfirm

# Install fonts
pacman -S awesome-terminal-fonts adobe-source-sans-pro-fonts cantarell-fonts noto-fonts ttf-bitstream-vera ttf-dejavu \
ttf-droid ttf-hack ttf-inconsolata ttf-liberation ttf-roboto ttf-ubuntu-font-family tamsyn-font --noconfirm

# Install media
pacman -S gwenview vlc gimp chromium --noconfirm

# Remove libreoffice logo
sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc

# Activate ftp server upload/download
sed -i 's/#write_enable=YES/write_enable=YES/g' /etc/vsftpd.conf
sed -i 's/#local_enable=YES/local_enable=YES/g' /etc/vsftpd.conf
sudo systemctl enable vsftpd.service

# Auto-start screenfetch in terminal
echo 'screenfetch' >> /home/juan/.bashrc

# Uncoment to mount unraid share
# echo 'documents /home/juan/Documents 9p trans=virtio,version=9p2000.L,_netdev,rw 0 0' >> /etc/fstab

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

# Install yay & pamac
cd /home/juan
git clone https://aur.archlinux.org/yay.git && chmod -R 777 yay && cd yay
# makepkg -si --noconfirm && yay -S pamac-aur --noconfirm

# Install icons - https://github.com/erikdubois/ArchXfce4
# cd /home/juan
# git clone https://github.com/erikdubois/ArchXfce4.git
# cd /home/juan/ArchXfce4/installation
# ./300-install-themes-icons-cursors-conky-v1.sh

echo "-[Desktop environment]---------------------"
echo "1: KDE"
echo "2: XFCE"
# echo "3: GNOME"
# echo "4: CINNAMON"
# echo "5: MATE"
# echo "6: "
echo "n: don't install any desktop environment"

while true; do
  read -p "Do you wish to install a Desktop environment? [1,n] : " ans
  case $ans in
     [1]* ) pacman -S plasma-desktop lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings breeze-gtk kde-gtk-config \
     xorg xorg-xinit xorg-server archlinux-wallpaper dolphin konsole spectacle yakuake plasma-browser-integration \
     kwalletmanager qt5-xmlpatterns --noconfirm
     echo "exec startkde" > ~/.xinitrc 
     systemctl enable lightdm; break;;
     
     [2]* ) pacman -S xfce4 xfce4-goodies xfce4-taskmanager xfce4-whiskermenu-plugin lightdm lightdm-gtk-greeter \
     lightdm-gtk-greeter-settings xorg xorg-xinit xorg-server archlinux-wallpaper breeze-gtk conky --noconfirm
     echo "exec startxfce4" > ~/.xinitrc
     systemctl enable lightdm; break;;      
     
#      [3]* ) /scripts/de-gnome.sh; break;;
    [Nn]* ) exit;;
  esac
done
echo "------------------------------------------------"
echo "type 'reboot' to restart your system"
exit
