#!/usr/bin/env bash

set -e

CMDLINE=$(cat /boot/efi/cmdline.txt)
VMLINUZ=/boot/efi/bzImage
INITRD=/boot/efi/initrd.img

kexec -l "$VMLINUZ" --initrd="$INITRD" --append="$CMDLINE"
systemctl kexec -i
