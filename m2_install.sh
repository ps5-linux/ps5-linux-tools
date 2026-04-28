#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "Run as root"
   exit 1
fi

MNT="/mnt/ps5_image_src"
NVME_PART="/dev/nvme0n1p1"
NVME_MNT="/mnt/ubuntu_m2"

usage() {
    echo "Usage: $0 --mount <image_file> | --install <image_file>"
    exit 1
}

if [ -z "$2" ]; then usage; fi

IMG="$2"

case "$1" in
    --mount)
        LOOP=$(losetup -Pf --show "$IMG")
        mkdir -p "$MNT"
        mount "${LOOP}p1" "$MNT"
        echo "Mounted $IMG to $MNT"
        echo "To unmount: sudo umount -R $MNT && sudo losetup -d $LOOP"
        ;;

    --install)
        if [ ! -b "$NVME_PART" ]; then
            echo "Error: $NVME_PART not found."
            exit 1
        fi

        umount -l "$NVME_PART" 2>/dev/null || true

        LOOP=$(losetup -Pf --show "$IMG")
        trap 'umount -R $MNT 2>/dev/null || true; losetup -d $LOOP 2>/dev/null || true' EXIT

        SRC_LABEL=$(blkid -s LABEL -o value "${LOOP}p1")
        NEW_LABEL="${SRC_LABEL:-PS5_ROOT}_m2"

        EFI_DEV=$(findmnt -n -o SOURCE /boot/efi)
        if [ -z "$EFI_DEV" ]; then
            echo "Error: Could not find active EFI partition at /boot/efi"
            exit 1
        fi

        EFI_LABEL=$(blkid -s LABEL -o value "$EFI_DEV")
        if [ -n "$EFI_LABEL" ]; then
            EFI_IDENTIFIER="LABEL=$EFI_LABEL"
        else
            EFI_UUID=$(blkid -s UUID -o value "$EFI_DEV")
            EFI_IDENTIFIER="UUID=$EFI_UUID"
        fi

        mkdir -p "$MNT"
        mount "${LOOP}p1" "$MNT"

        echo "Formatting $NVME_PART as ext4 with label: $NEW_LABEL"
        mkfs.ext4 -F -L "$NEW_LABEL" "$NVME_PART"

        mkdir -p "$NVME_MNT"
        mount "$NVME_PART" "$NVME_MNT"

        echo "Copying files to M.2..."
        cp -a "$MNT/." "$NVME_MNT/"

        echo "Generating /etc/fstab..."
        cat <<EOF > "$NVME_MNT/etc/fstab"
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
LABEL=$NEW_LABEL / ext4 defaults 0 1
$EFI_IDENTIFIER /boot/efi vfat defaults 0 1
EOF

        echo "Cleaning up..."
        umount "$NVME_MNT"
        rmdir "$NVME_MNT" "$MNT" 2>/dev/null || true

        echo "Installation complete."
        ;;

    *)
        usage
        ;;
esac

