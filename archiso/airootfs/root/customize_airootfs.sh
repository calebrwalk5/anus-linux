#!/bin/bash

function setumask()
{
	set -e -u
	umask 022
	echo "#####   Function setumask done    #####"
}

function setTimeZoneAndClock()
{
	# Timezone
	ln -sf /usr/share/zoneinfo/UTC /etc/localtime
	# Set clock to UTC
	hwclock --systohc --utc
	echo "#####   Function setTimeZoneAndClock done    #####"
}

function editOrCreateConfigFiles()
{
	# Locale
	echo "LANG=en_US.UTF-8" > /etc/locale.conf

	sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
	sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
	sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
	echo "#####   Function editOrCreateConfigFiles done    #####"
}

function configRootUser()
{
	usermod -s /usr/bin/bash root
	cp -aT /etc/skel/ /root/
	chmod 750 /root
	echo "#####   Function configRootUser done    #####"
}

function createLiveUser()
{
	# add liveuser
	useradd -m liveuser -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash
	chown -R liveuser:users /home/liveuser

	#enable autologin
	groupadd -r autologin
	gpasswd -a liveuser autologin

	groupadd -r nopasswdlogin
	gpasswd -a liveuser nopasswdlogin
	echo "#####   Function createLiveUser done    #####"
}

function setDefaults()
{
	export _EDITOR=nano
	echo "EDITOR=${_EDITOR}" >> /etc/environment
	echo "EDITOR=${_EDITOR}" >> /etc/profile
	echo "#####   Function setDefaults done    #####"
}

function fixHaveged()
{
	systemctl enable haveged
	echo "#####   Function fixHaveged done    #####"
}

function fixPermissions()
{
	chmod 750 /etc/sudoers.d
	chmod 750 /etc/polkit-1/rules.d
	chgrp polkitd /etc/polkit-1/rules.d
	echo "#####   Function fixPermissions done    #####"
}

function enableServices()
{
	systemctl enable lightdm.service
	systemctl set-default graphical.target
	systemctl enable NetworkManager.service
	systemctl enable virtual-machine-check.service
	systemctl enable reflector.service
	systemctl enable reflector.timer
	systemctl enable org.cups.cupsd.service
	systemctl enable bluetooth.service
	systemctl enable ntpd.service
	systemctl enable avahi-daemon.service
	systemctl enable avahi-daemon.socket
	echo "#####   Function enableServices done    #####"
}

function fixGeoclueRedshift()
{
	pathToGeoclueConf="/etc/geoclue/geoclue.conf"
	echo '' >> $pathToGeoclueConf
	echo '[redshift]' >> $pathToGeoclueConf
	echo 'allowed=true' >> $pathToGeoclueConf
	echo 'system=false' >> $pathToGeoclueConf
	echo 'users=' >> $pathToGeoclueConf
	echo "#####   Function fixGeoclueRedshift done    #####"
}

function fixWifi()
{
	#https://wiki.archlinux.org/index.php/NetworkManager#Configuring_MAC_Address_Randomization
	su -c 'echo "" >> /etc/NetworkManager/NetworkManager.conf'
	su -c 'echo "[device]" >> /etc/NetworkManager/NetworkManager.conf'
	su -c 'echo "wifi.scan-rand-mac-address=no" >> /etc/NetworkManager/NetworkManager.conf'
	echo "#####   Function fixWifi done    #####"
}


function fixHibernate()
{
	sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
	sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
	sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
	echo "#####   Function fixHibernate done    #####"
}

function initkeys()
{
	pacman-key --init
	pacman-key --populate archlinux
	pacman-key --populate arcolinux
	pacman-key --lsign-key 74F5DE85A506BF64
	echo "#####   Function initkeys done    #####"
}

function getNewMirrorCleanAndUpgrade()
{
	reflector --protocol https --latest 50 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
	pacman -Sc --noconfirm
	pacman -Syyu --noconfirm
	echo "#####   Function getNewMirrorCleanAndUpgrade done    #####"
}

function installPackages()
{
	# File Manager
	pacman -S --noconfirm thunar

	# VisualStudio Code
	pacman -S --noconfirm code

	# Chromium
	pacman -S --noconfirm chromium

	# CARS
	git clone https://github.com/calebrwalk5/cars
	gcc cars.c -o cars
	chmod +x cars
	./cars

	# Yay
	pacman -S --noconfirm yay

	# GCC
	pacman -S --noconfirm gcc

	# Vim
	pacman -S vim
}

function installAurPackages()
{
	# Make sure needed packages are installed
	pacman -S --noconfirm git

	# Theme
	git clone https://aur.archlinux.org/flat-remix-git.git ~/flat-remix-git
	cd ~/flat-remix-git
	makepkg -si

	# Icon
	git clone https://aur.archlinux.org/flat-remix-gtk.git ~/flat-remix-gtk
	cd ~/flat-remix-gtk
	makepkg -si

	# Mega
	git clone https://aur.archlinux.org/megasync.git ~/megasync
	cd ~/flat-remix-gtk
	makepkg -si

	# Mega Extention
	git clone https://aur.archlinux.org/nautilus-megasync.git ~/nautilus-megasync
	cd ~/nautilus-megasync
	makepkg -si

	# GitKraken
	git clone https://aur.archlinux.org/gitkraken.git ~/gitkraken
	cd ~/gitkraken
	makepkg -si
}



echo
echo "##########################################################"
echo "##########################################################"
setumask
setTimeZoneAndClock
editOrCreateConfigFiles
configRootUser
createLiveUser
setDefaults
fixHaveged
fixPermissions
enableServices
fixGeoclueRedshift
fixWifi
fixHibernate
initkeys
getNewMirrorCleanAndUpgrade
installPackages
installAurPackages
echo "##########################################################"
echo "##########################################################"
echo
