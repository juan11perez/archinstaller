#!/bin/sh
wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/master/post-install.sh
wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/master/install.sh
# wget https://raw.githubusercontent.com/juan11perez/Arch-Installer/300-install-themes-icons-cursors-conky-v1.sh

echo "disk to format (sdx,vdx,nvme0n1)?"
read which
sed -i "s/disk=vda/disk=$which/g" /root/post-install.sh
sed -i "s/disk=vda/disk=$which/g" /root/install.sh

chmod +x *.sh
./install.sh
