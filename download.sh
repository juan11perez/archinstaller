#!/bin/sh

wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/master/post-install.sh
wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/master/install.sh

echo "device to format (sdx,vdx,nvme0n1)?"
read which
sed -i "s/disk=vda/disk=$which/g" /root/post-install.sh
sed -i "s/disk=vda/disk=$which/g" /root/install.sh

echo "enter new user name"
read user
sed -i "s/juan/$user/g" /root/post-install.sh

read -p 'do you want to mount an unraid share? [y/N]: ' unraid
if [ $unraid = 'y' ] || [ $unraid = 'Y' ]
then 
  sed -i "s/# echo 'documents/echo 'documents/g" /root/post-install.sh
fi

read -p 'do you require bluetooth? [y/N]: ' bluetooth
if [ $bluetooth = 'y' ] || [ $bluetooth = 'Y' ]
then 
  sed -i "s/# pacman -S pulseaudio-bluetooth/pacman -S pulseaudio-bluetooth/g" /root/post-install.sh
  sed -i "s/# systemctl enable bluetooth.service/systemctl enable bluetooth.service/g" /root/post-install.sh
fi

read -p 'is this a laptop installation? [y/N]: ' laptop
if [ $laptop = 'y' ] || [ $laptop = 'Y' ]
then 
  sed -i "s/# pacman -S tlp/pacman -S tlp/g" /root/post-install.sh
  sed -i "s/# systemctl enable tlp.service/systemctl enable tlp.service/g" /root/post-install.sh
fi

chmod +x *.sh
./install.sh
