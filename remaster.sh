#!/bin/bash
# MIT License. See LICENSE file.

# GRUB2 CAVEAT: Some non-Alpine installations of grub2 will create ${ISO}/boot/grub2 instead of ${ISO}/boot/grub which will generally lead to broken installation media.
# Be mindful of this and modify the below command accordingly.
# Systems that exhibit this behavior typically have grub2-mkrescue on the path instead of grub-mkrescue.
GRUB_CMD=grub-mkrescue # For Ubuntu

[[ $# -ne 1 ]] && { echo "Usage: ./k3os-remaster.sh [k3os-version].iso"; exit 1; }
BASE_ISO=$1
NEW_ISO="isos/new/remastered-$(basename ${BASE_ISO})"

# Check if given BASE_ISO is really a k3OS iso image
if [ -f ${BASE_ISO} ] ; then
	BLKID=$(blkid ${BASE_ISO})
	[[ $(echo ${BLKID} | grep 'TYPE="iso9660"' | grep 'LABEL="K3OS"') ]] || { echo "${BASE_ISO} must be an ISO image of k3OS !"; exit 1; }
else
	echo "${BASE_ISO} is not a file..."
	exit 1
fi

# Mount base k3OS image
mkdir -p /mnt/base-iso
mount -o loop ${BASE_ISO} /mnt/base-iso

# Copy data from base to new
mkdir -p /mnt/new-iso
cp -rfp /mnt/base-iso/k3os /mnt/new-iso/

# Copy the custom grub.cfg to the new boot directory
mkdir -p /mnt/new-iso/boot/grub
cp custom_grub.cfg /mnt/new-iso/boot/grub/grub.cfg
chmod 444 /mnt/new-iso/boot/grub/grub.cfg
chown root:root /mnt/new-iso/boot/grub/grub.cfg

# Make remastered ISO
echo "Building image to ${NEW_ISO}..."
${GRUB_CMD} -o ${NEW_ISO} /mnt/new-iso/ -- -volid "K3OS" 2> build.log

# Check remastered ISO
FILESIZE=$(stat -c %s ${NEW_ISO} 2>/dev/null)
if [[ $FILESIZE > 0 ]]; then
	printf '%s (%d bytes) ... done!\n' ${NEW_ISO} $FILESIZE
else
	printf 'Something went wrong while trying to make %s\n' ${NEW_ISO}
fi

# Cleanup
umount /mnt/base-iso
rm -rf /mnt/new-iso /mnt/base-iso