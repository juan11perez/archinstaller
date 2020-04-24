#! /bin/bash

# This is Krushn's Arch Linux Installation Script.
# Visit krushndayshmookh.github.io/krushn-arch for instructions.

echo "Arch Installer"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then 
    echo "Connect to internet to continue..."
    exit
fi

# Install closest mirrors 
pacman -Sy  reflector --noconfirm
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
# reflector -c “India” -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist 

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo "/dev/vda1 - 512Mib will be mounted as /boot/efi"
echo "/dev/vda2 - 10GiB will be used as root"
echo "/dev/vda3 - rest of space will be mounted as home"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then 
    echo "Edit the script to continue..."
    exit
fi

# to create the partitions programatically (rather than manually)
# https://superuser.com/a/984637
(
echo  o # clear the in memory partition table
echo  n # new partition
echo  p # primary partition
echo  1 # partition number 1
echo    # default - start at beginning of disk 
echo  +512M # 512 MB boot parttion
echo  n # new partition
echo  p # primary partition
echo  2 # partion number 2
echo    # default, start immediately after preceding partition
echo  +10G # 10 GB root parttion
echo  n # new partition
echo  p # primary partition
echo  3 # partion number 3
echo    # default, start immediately after preceding partition
echo    # default, extend partition to end of disk
echo  a # make a partition bootable
echo  1 # bootable partition is partition 1 -- /dev/vda1
echo  p # print the in-memory partition table
echo  w # write the partition table
echo  q # and we're done
) | sudo fdisk

# Format the partitions
mkfs.fat -F32 /dev/vda1
mkfs.ext4 /dev/vda2
mkfs.ext4 /dev/vda3


# Set up time
timedatectl set-ntp true

# Initate pacman keyring
# pacman-key --init
# pacman-key --populate archlinux
# pacman-key --refresh-keys

# Mount the partitions
mkdir -pv /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi
mount /dev/vda2 /mnt
mkdir /mnt/home
mount /dev/vda3 /mnt/home

# Install Arch Linux
echo "Starting install.."
echo "Installing Arch Linux" 
pacstrap -i /mnt base linux linux-firmware sudo nano  --noconfirm
# pacstrap /mnt base base-devel zsh grml-zsh-config grub os-prober intel-ucode efibootmgr dosfstools freetype2 fuse2 mtools iw wpa_supplicant dialog xorg xorg-server xorg-xinit mesa xf86-video-intel plasma konsole dolphin

# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Copy post-install system cinfiguration script to new /root
cp *.sh /mnt/ &>/dev/null
# arch-chroot /mnt /bin/bash
# arch-chroot /mnt /scripts/post-install.sh
# cp -rfv post-install.sh /mnt/root
# chmod a+x /mnt/root/post-install.sh

# Chroot into new system
echo "After chrooting into newly installed OS, please run the post-install.sh by executing ./post-install.sh"
echo "Press any key to chroot..."
read tmpvar
arch-chroot /mnt /bin/bash

# Finish
echo "If post-install.sh was run succesfully, you will now have a fully working bootable Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
