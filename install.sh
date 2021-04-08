#! /bin/bash

# Arch Linux Installation Script.
echo "Arch Installer"

# Disk variable
disk=vda

# Set up network connection
#read -p 'Are you connected to internet? [y/N]: ' neton
#if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
#then 
#    echo "Connect to internet to continue..."
#    exit
#fi

# Install closest mirrors 
pacman -Sy  reflector --noconfirm
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
# reflector -c “India” -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist 

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo "/dev/vda1 - 512Mib will be mounted as /boot/efi"
echo "/dev/vda2 - 40GiB will be used as root"
echo "/dev/vda3 - rest of space will be mounted as home"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then 
    echo "Edit the script to continue..."
    exit
fi

# to create the partitions programatically (rather than manually)
# https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/$disk
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +40G # 20 GB root parttion
  n # new partition
  p # primary partition
  3 # partion number 3
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/vda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

# Format the partitions
mkfs.fat -F32 /dev/${disk}1
mkfs.ext4 /dev/${disk}2
mkfs.ext4 /dev/${disk}3

# Set up time
timedatectl set-ntp true

# Initate pacman keyring
# pacman-key --init
# pacman-key --populate archlinux
# pacman-key --refresh-keys

# Mount the partitions
mount /dev/${disk}2 /mnt
mkdir /mnt/home
mount /dev/${disk}3 /mnt/home

# Install Arch Linux
echo "Starting install.."
echo "Installing Arch Linux" 
pacstrap -i /mnt base base-devel linux linux-firmware sudo nano --noconfirm

# Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Copy post-install system configuration scripts to new /root
cp -rfv post-install.sh /mnt
chmod a+x /mnt/post-install.sh

# Chroot into new system
echo "After chrooting into newly installed OS, please run the post-install.sh by executing ./post-install.sh"
echo "Press any key to chroot..."
read tmpvar
arch-chroot /mnt /bin/bash
cd /tmp

# Finish
echo "If post-install.sh was run succesfully, you will now have a fully working bootable Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
