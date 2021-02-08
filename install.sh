#!bin/bash
#Variables
hostname = 'host'
timezone = 'America/Toronto'
username = 'user'

#Netcheck
echo "You must be connected to the Internet."
read -p 'Are you connected? [Y/N]: ' netcheck 
if ! [ $netcheck = 'y' ] && ! [ $netcheck = 'Y' ]
then    
    echo "Please connect to the internet first..."
    exit
fi

#Partitioning (Manual)

function partitioning{
    clear_console
    echo "You will have to create a partition table."
    echo "The first must be at least 512Mib as EFI"
    echo "The second should be at least 2GiB as Linux Swap"
    echo "The last should be the rest of your disc as Linux File System"
    read -p 'Press Y if you understand: ' psa
    if ! [ $psa = 'y' ] && ! [ $psa = 'Y' ] 
    then 
        partitioning
    else
        cfdisk /dev/sda
    fi
    }

#Formating created Partitions
mkfs.ext /dev/sda3
mkfs.fat -F32 /dev/sda1

#Setting up time
timedatectl set-ntp true
timedatectl set-timezone $timezone

#Mounting Partitions
mount /dev/sda3 /mnt 
mkdir /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
mkswap /dev/sda2
swapon /dev/sda2

#Installing Arch
pacstrap /mnt base base-devel 

#Generating fstab
genfstab -U /mnt /mnt/etc/fstab

#chroot
arch-chroot /mnt

#Set date & time
ln -sf /usr/share/zoneinfo$timezone /etc/localtime
hwclock --systohc

#Install grub
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

#Setting locale to en_US.UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
local-gen
echo "LANG=en_US.UTF-8 >> /etc/locale.conf"

#Setting hostname
echo $hostname >> /etc/hostname
echo "127.0.1.1 $hostname.localdomain   $hostname" >> /etc/hosts

#Generating intramfs
mkinitcpio -P

#Installing some packages
pacman -Syu
pacman -S grub os-prober efibootmgr dosfstools sudo cinnamon nemo-fileroller bash-completion xorg-server xorg-xinit xorg-utils xorg-server-utils mesa gdm net-tools networkmanager network-manager-applet
pacman -S pulseaudo pulseaudio-alsa pavucontrol gnome-terminal firefox flashplugin vlc unzip unrar p7zip pidgin smplayer deluge audacious qmmp gimp xfburn gedit nano gnome-gnome-system-monitor libgtop
pacman -S a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gstreamer0.10-plugins

#Set Rootpassword
echo "Please enter a password for the root user..."
passwd

#Creating a new user
useradd -aG wheel,input,storage,video,audio $username
sed --in-place 's/^#\s*\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for $username"
passwd $username

systemctl enable NetworkManager
systemctl start NetworkManager

systemctl enable gdm
systemctl start gdm


