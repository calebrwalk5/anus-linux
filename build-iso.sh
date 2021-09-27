#!/bin/bash
project_dir=/opt/anus-linux

echo
echo "##################################################"
echo "Phase 0 : Set build number"
echo "##################################################"
echo
sed -i 's/VERSION_NUMBER/'`date -u +"%F.%R"`'/g' ${project_dir}/archiso/build.sh
sed -i 's/VERSION_NUMBER/'`date -u +"%F.%R"`'/g' ${project_dir}/archiso/airootfs/etc/os-release
sed -i 's/VERSION_NUMBER/'`date -u +"%F.%R"`'/g' ${project_dir}/archiso/airootfs/etc/lsb-release

echo
echo "##################################################"
echo "Phase 1 : Get the latest bashrc from github"
echo "##################################################"
echo
echo "Removing old files/folders from folder"
rm -rf ${project_dir}/archiso/airootfs/etc/skel/.* 2> /dev/null
echo "getting .bashrc from arcolinux-root"
wget https://raw.githubusercontent.com/calebrwalk5/cars/main/.bashrc -O ${project_dir}/archiso/airootfs/etc/skel/.bashrc
echo ".bashrc copied to /etc/skel"


echo
echo "##################################################"
echo "Phase 2 : Checking if archiso is installed"
echo "##################################################"
echo
echo "Checking if archiso is installed"

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then
		echo $package is already installed

else

	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then
		echo Installing $package with yay
		yay -S --noconfirm $package

	elif pacman -Qi trizen &> /dev/null; then
		echo Installing $package with trizen
		trizen -S --noconfirm --needed --noedit $package

	elif pacman -Qi yaourt &> /dev/null; then
		echo Installing $package with yaourt
		yaourt -S --noconfirm $package

	elif pacman -Qi pacaur &> /dev/null; then
		echo Installing $package with pacaur
		pacaur -S --noconfirm --noedit  $package

	elif pacman -Qi packer &> /dev/null; then
		echo Installing $package with packer
		packer -S --noconfirm --noedit  $package
	else
		echo Installing $package with pacman
		pacman -S --noconfirm $package
	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then
		echo $package has been installed

	else
		echo !!!!! $package has NOT been installed

	fi

fi


echo
echo "##################################################"
echo "Phase 3 : Making sure we start with a clean slate"
echo "##################################################"
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d ~/anus-linux-build ] && rm -rf ~/anus-linux-build


echo
echo "##################################################"
echo "Phase 4 : Moving files to violalinux-build folder"
echo "##################################################"
echo
echo "Copying files and folder to /opt/Viola-linux/violalinux-build"
cp -r ${project_dir} ~/anus-linux-build

chmod 750 ~/anus-linux-build/archiso/airootfs/etc/sudoers.d
chmod 750 ~/anus-linux-build/archiso/airootfs/etc/polkit-1/rules.d
chgrp polkitd ~/anus-linux-build/archiso/airootfs/etc/polkit-1/rules.d

echo
echo "##################################################"
echo "Phase 5 : Cleaning the cache"
echo "##################################################"
echo
pacman -Scc --noconfirm


echo
echo "##################################################"
echo "Phase 6 : Building the iso"
echo "##################################################"
echo

cd ~/anus-linux-build/archiso/
./build.sh -v

echo
echo "##################################################"
echo "Phase 7 : Copying the iso to ~/anus-linux-out"
echo "##################################################"
echo
[ -d  ~/anus-linux-out ] || mkdir ~/anus-linux-out
cp ~/anus-linux-build/archiso/out/anus-linux* ~/anus-linux-out
