#!/bin/bash

#Shit to be done in jyubuntu-create script chroot

LANG=C
echo "Updating APT database..."
apt update
sleep 1
echo "Installing casper stuff..."
apt -y install casper lupin-casper
sleep 1
echo "Installing Recovery stuff..."
apt -y install gparted testdisk wipe partimage xfsprogs reiserfsprogs jfsutils ntfs-3g dosfstools mtools
sleep 1
echo "Updating initramfs..."
depmod -a $(uname -r)
update-initramfs -u -k $(uname -r)
sleep 1
echo "Removing non-system users..."
for i in `cat /etc/passwd | awk -F":" '{print $1}'`
do
        uid=`cat /etc/passwd | grep "^${i}:" | awk -F":" '{print $3}'`
        [ "$uid" -gt "998" -a  "$uid" -ne "65534"  ] && userdel --force ${i} 2> /dev/null
done
sleep 1
echo "Cleaning APT cache..."
apt-get clean
sleep 1
echo "Shitcanning the extra log files..."
find /var/log -regex '.*?[0-9].*?' -exec rm -v {} \;
find /var/log -type f | while read file
do
        cat /dev/null | tee $file
done
sleep 1
echo "Deleting the unneeded network stuff for live environment..."
echo "(mostly the files /etc/hostname and /etc/resolv.conf)"
rm /etc/resolv.conf /etc/hostname
sleep 1
echo "Done..."
sleep 3
