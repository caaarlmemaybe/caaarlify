#!/bin/bash

#Install an AUR package manually.
aurinstall() { curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz && tar -xvf $1.tar.gz && cd $1 && makepkg --noconfirm -si && cd .. && rm -rf $1 $1.tar.gz ;}

#aurcheck runs on each of its arguments, if the argument is not already installed, it either uses packer to install it, or installs it manually.
aurcheck() {
qm=$(pacman -Qm | awk '{print $1}')
for arg in "$@"
do
if [[ $qm = *"$arg"* ]]; then
	echo $arg is already installed.
else
	echo $arg not installed.
	packer --noconfirm -S $arg >/dev/null || aurinstall $arg
fi
done
}

dialog --infobox "Installing \"packer\", an AUR helper..." 10 60
aurcheck packer >/dev/null

count=$(cat /tmp/aur_queue | wc -l)
n=0

for prog in $(cat /tmp/aur_queue)
do
	n=$((n+1))
	dialog --infobox "Downloading and installing program $n out of $count: $prog..." 10 60
	aurcheck $prog >/dev/null
done

echo Downloading config files...

git clone https://github.com/caaarlmemaybe/caaarlify.git >/dev/null && rsync -va caaarlify/dotfiles/ /home/$(whoami) >/dev/null && rm -rf caaarlify >/dev/null

dialog --infobox "Reseting Pulseaudio..." 4 50
killall pulseaudio >/dev/null
pulseaudio --start >/dev/null
