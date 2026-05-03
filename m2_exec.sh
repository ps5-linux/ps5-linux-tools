#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

NVME_PART="/dev/nvme0n1p1"
MNT="/tmp/kexec_mnt"

usage() {
    echo "Usage: $0 [--reboot]"
    echo "  no args   Mount $NVME_PART and kexec into its kernel"
    echo "  --reboot  Kexec into the current system's own /boot kernel"
}

case "${1:-}" in
    "")
        ;;
    --reboot)
        VMLINUZ="/boot/vmlinuz"
        INITRD="/boot/initrd.img"

        if [[ ! -f "$VMLINUZ" ]]; then
            VMLINUZ=$(ls -v /boot/vmlinuz* | tail -n 1)
            INITRD=$(ls -v /boot/initrd.img* | tail -n 1)
        fi

        if [[ ! -f "$VMLINUZ" ]]; then
            echo "Error: Could not find a kernel in /boot"
            exit 1
        fi

        if [[ ! -f "$INITRD" ]]; then
            echo "Error: Could not find an initrd in /boot"
            exit 1
        fi

        echo "kernel: $VMLINUZ"
        echo "initrd: $INITRD"

        CMDLINE=$(cat /proc/cmdline | xargs)

        echo "cmdline: $CMDLINE"

        kexec -l "$VMLINUZ" \
              --initrd="$INITRD" \
              --append="$CMDLINE"

        echo "Executing kexec reboot..."
        systemctl kexec -i
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

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
