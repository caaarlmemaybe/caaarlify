#!/bin/bash

pacman -S --noconfirm --needed dialog || { echo "Error at script start: Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection?"; exit; }
#dialog --title "Welcome!" --msgbox "Welcome to Luke's Auto-Rice Bootstrapping Script!\n\nThis script will automatically install a fully-featured i3wm Arch Linux desktop, which I use as my main machine.\n\n-Luke" 10 60

name=$(dialog --no-cancel --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1)
pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)

while [ $pass1 != $pass2 ]
do
	pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\n\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	unset pass2
done

dialog --infobox "Adding user \"$name\"..." 4 50
useradd -m -g wheel -s /bin/bash $name >/dev/tty6
echo "$name:$pass1" | chpasswd >/dev/tty6

cmd=(dialog --separate-output --nocancel  --buildlist "Press <SPACE> to select the packages you dont want to install. I recommend to leave everything checked though.

Use \"^\" and \"\$\" to move to the left and right columns respectively. Press <ENTER> when done." 22 76 16)
options=(G "Essentials" on
         R "Tools like Filemanager, Browser, etc." on
         X "LaTeX packages" on
	 U "Utilities for media, ntfs systems etc" on
	 )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

let="\(\|[a-z]\|$(echo $choices | sed -e "s/ /\\\|/g")\)"

dialog --title "Let's get this party started!" --msgbox "The rest of the installation will now be totally automated, so you can sit back and relax.\n\nIt will take some time, but when done, you can relax even more with your complete system.\n\nNow just press <OK> and the system will begin installation!" 13 60 || { clear; exit; }

clear

dialog --infobox "Refreshing Arch Keyring..." 4 40
pacman --noconfirm -Sy archlinux-keyring >/dev/tty6

dialog --infobox "Getting program list..." 4 40
curl https://raw.githubusercontent.com/caaarlmemaybe/caaarlify/master/packagelist.csv > /tmp/packagelist.csv
rm /tmp/aur_queue &>/dev/tty6
count=$(cat /tmp/packagelist.csv | grep -G ",$let," | wc -l)
n=0
installProgram() { ( (pacman --noconfirm --needed -S $1 &>/dev/tty6 && echo $1 installed.) || echo $1 >> /tmp/aur_queue) || echo $1 >> /tmp/packages_failed ;}

for x in $(cat /tmp/packagelist.csv | grep -G ",$let," | awk -F, {'print $1'})
do
	n=$((n+1))
	dialog --title "Package Installation" --infobox "Downloading and installing package $n out of $count: $x...\n\nThis may take a while. You can watch the output on tty6." 8 70
	installProgram $x >/dev/tty6
done

dialog --infobox "Preparing the user script..." 4 40
curl https://raw.githubusercontent.com/caaarlmemaybe/caaarlify/master/sudoers_tmp > /etc/sudoers
cd /tmp
curl https://raw.githubusercontent.com/caaarlmemaybe/caaarlify/master/setup_user.sh > /tmp/setup_user.sh;
sudo -u $name bash /tmp/setup_user.sh

dialog --infobox "Installing \"st\" from source..." 4 40
cd /tmp
rm -rf st
git clone https://github.com/lukesmithxyz/st.git
cd st
make
make install
cd /tmp

# R markdown install.

dialog --infobox "Enabling Network Manager..." 4 40
systemctl enable NetworkManager
systemctl start NetworkManager

dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

dialog --infobox "Updating sudoers file..." 4 40

curl https://raw.githubusercontent.com/caaarlmemaybe/caaarlify/master/sudoers  > /etc/sudoers

dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be in place.\n\nTo run the new graphical environment, log out and log back in as your new user, then run the command \"startx\" to start the graphical environment.\n\n-Carl" 12 80
clear
