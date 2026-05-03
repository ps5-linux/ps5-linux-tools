#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

NVME_PART="/dev/nvme0n1p1"
MNT="/tmp/kexec_mnt"

ROOT_LABEL=$(blkid -s LABEL -o value "$NVME_PART")

if [ -z "$ROOT_LABEL" ]; then
    echo "Error: Could not find label for $NVME_PART. Ensure the install script ran successfully."
    exit 1
fi

echo "Mounting $NVME_PART ($ROOT_LABEL)..."

mkdir -p "$MNT"
mount -o ro "$NVME_PART" "$MNT"

VMLINUZ="$MNT/boot/vmlinuz"
INITRD="$MNT/boot/initrd.img"

if [[ ! -f "$VMLINUZ" ]]; then
    VMLINUZ=$(ls -v $MNT/boot/vmlinuz* | tail -n 1)
    INITRD=$(ls -v $MNT/boot/initrd.img* | tail -n 1)
fi

echo "kernel: $VMLINUZ"
echo "initrd: $INITRD"

CMDLINE=$(cat /proc/cmdline | \
    sed -e 's/video=[^ ]*//g' \
        -e "s|root=[^ ]*|root=LABEL=$ROOT_LABEL|g" | \
    xargs)

echo "cmdline: $CMDLINE"

kexec -l "$VMLINUZ" \
      --initrd="$INITRD" \
      --append="$CMDLINE"

echo "Unmounting and executing..."
umount "$MNT"

systemctl kexec -i
