#!/bin/bash

# JYubuntu Live ISO creator
# Based upon instructions from 
# https://help.ubuntu.com/community/MakeALiveCD/DVD/BootableFlashFromHarddiskInstall
#
# (C) 2018-12-21 Alexandra Tilbrook KI5JYD <ki5jyd@gmail.com>
# and Daphne Tilbrook (XYL) <ki5jyd.xyl@gmail.com>
# https://dollsbook.com
# Licensed under GNU GPL 3 and CC BY 4.0
# Some rights reserved.

# Check if this shit's running as root
if [[ $EUID -ne 0 ]]; then
   echo "This must be run as root."
   echo "Please run again with"
   echo "sudo $0" 
   echo
   exit 1
fi
export my_dir=`dirname $0`
# Welcome
clear
echo "Welcome to the JYubuntu Live ISO creator!"
echo "This script will make a live ISO ready to share with your homies."
echo
echo "This script is based upon the directions at"
echo "https://help.ubuntu.com/community/MakeALiveCD/DVD/BootableFlashFromHarddiskInstall"
echo "With some necessary modifications."
echo 
echo "I believe in the KISS (Keep It Simple, Stupid) philosophy. This creator is pretty straightforward and automatic."
echo "No questions will be asked. It is assumed that /etc/skel is set up properly and other directories."
echo
echo "When you are ready, please close ALL open applications, unmount any other drives,"
read -n 1 -s -r -p "and press any key to continue or CTRL+C to quit. "

# Final warning
clear
echo "We are going to continue!!!"
echo 
echo "This script will continue in 10 seconds."
echo "This is your last chance to back out. If you wish to continue,"
echo "Just sit back and enjoy it. Go do something else."
echo "But if you need to cancel NOW..."
echo "PRESS CONTROL+C."
sleep 10
echo
echo "We are continuing."
# Now the magic begins.
clear
echo "Creating environment variables..."
export WORK=$my_dir/work
export CD=$my_dir/cd
export FORMAT=squashfs
export FS_DIR=casper
echo "Creating live ISO directories..."
mkdir -p ${CD}/{${FS_DIR},boot/grub} ${WORK}/rootfs
#echo "Updating the APT package database"
#apt-get update
#sleep 2
#echo "Now installing required packages grub-pc, xorriso and squashfs-tools..."
#apt-get -y install grub-pc xorriso squashfs-tools
sleep 2
echo "Now copying your installed system to the temp area."
echo "This WILL take a while."
sleep 5
rsync -av --one-file-system --exclude=/proc/* --exclude=/dev/* \
--exclude=/sys/* --exclude=/tmp/* --exclude=/home/* --exclude=/lost+found \
--exclude=/var/tmp/* --exclude=/boot/grub/* --exclude=/root/* \
--exclude=/var/mail/* --exclude=/var/spool/* --exclude=/media/* \
--exclude=/etc/fstab --exclude=/etc/mtab --exclude=/etc/hosts \
--exclude=/etc/timezone --exclude=/etc/shadow* --exclude=/etc/gshadow* \
--exclude=/etc/X11/xorg.conf* --exclude=/etc/gdm/custom.conf \
--exclude=/etc/lightdm/lightdm.conf --exclude=/swapfile --exclude=${WORK}/rootfs / ${WORK}/rootfs >/dev/null 2>&1
sleep 2
echo "Now copying your customizations..."
CONFIG='$HOME/.config'
for i in $CONFIG
do
cp -rpv --parents $i ${WORK}/rootfs/etc/skel >/dev/null 2>&1
done
cp $HOME/.bashrc ${WORK}/rootfs/etc/skel
sleep 2
echo "Copying a couple of other things..."

echo "Copying required chroot script..."
cp $my_dir/jyubuntu-chroot.sh ${WORK}/rootfs/jyubuntu-chroot.sh
sleep 2
echo "Making networking work in chroot..."
cp /etc/resolv.conf ${WORK}/rootfs/etc/resolv.conf
echo "Done."
sleep 2
clear
echo "Now making the chroot environment..."
mount  --bind /dev/ ${WORK}/rootfs/dev
mount -t proc proc ${WORK}/rootfs/proc
mount -t sysfs sysfs ${WORK}/rootfs/sys
mount -o bind /run ${WORK}/rootfs/run
sleep 3
clear
echo "Now the real magic begins."
chroot ${WORK}/rootfs ./jyubuntu-chroot.sh
sleep 1
clear
echo "Now that's done, we're now making the CD directory tree."
sleep 1
export kversion=`cd ${WORK}/rootfs/boot && ls -1 vmlinuz-* | tail -1 | sed 's@vmlinuz-@@'`
echo "Copying vmlinuz..."
cp -vp ${WORK}/rootfs/boot/vmlinuz-${kversion} ${CD}/${FS_DIR}/vmlinuz
echo "Copying initial ramdisk..."
cp -vp ${WORK}/rootfs/boot/initrd.img-${kversion} ${CD}/${FS_DIR}/initrd.img
echo "Copying memtest86+..."
cp -vp ${WORK}/rootfs/boot/memtest86+.bin ${CD}/boot
echo "Generating Manifest for Live ISO..."
chroot ${WORK}/rootfs dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee ${CD}/${FS_DIR}/filesystem.manifest >/dev/null 2>&1
cp -v ${CD}/${FS_DIR}/filesystem.manifest{,-desktop}
REMOVE='ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
for i in $REMOVE
do
        sudo sed -i "/${i}/d" ${CD}/${FS_DIR}/filesystem.manifest-desktop
done
sleep 2
echo "Cleaning up..."
umount ${WORK}/rootfs/proc
umount ${WORK}/rootfs/sys
umount ${WORK}/rootfs/dev
sleep 1
echo "Now making squashfs for the JYubuntu Live ISO."
echo "This WILL take quite some time. Go get some Whataburger while I do this."
mksquashfs ${WORK}/rootfs ${CD}/${FS_DIR}/filesystem.${FORMAT} -no-recovery -always-use-fragments -b 1048576 -comp xz -Xbcj x86
sleep 1
echo "Calculating filesystem size..."
echo -n $(sudo du -s --block-size=1 ${WORK}/rootfs | tail -1 | awk '{print $1}') | sudo tee ${CD}/${FS_DIR}/filesystem.size
echo
echo "Calculating MD5sum..."
find ${CD} -type f -print0 | xargs -0 md5sum | sed "s@${CD}@.@" | grep -v md5sum.txt | sudo tee -a ${CD}/md5sum.txt
sleep 1
echo "Copying GRUB for the Live environment..."
cp $my_dir/grub-tmp.cfg ${CD}/boot/grub/grub.cfg
cp $my_dir/jydoll_grub.png ${CD}/boot/grub/jydoll_grub.png
sleep 1
clear
echo "Making the Live ISO now!"
grub-mkrescue -o ~/JYubuntu_amd64.iso ${CD}
sleep 1
clear
echo "We are done!!!!!!"
echo "To make sure that this works, run it in VirtualBox or your"
echo "preferred VM environment before committing to release."
echo 
echo "Thanks for your time and patience."
echo
echo "Hope to hear you on the air soon!!"
echo "73, KI5JYD"
echo
