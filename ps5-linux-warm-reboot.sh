#!/usr/bin/env bash
set -e

# Cleanly unload WiFi driver before kexec so the PCIe device
# isn't left in a dirty state for the new kernel
modprobe -r moal mlan 2>/dev/null || true

CMDLINE=$(cat /boot/efi/cmdline.txt)
VMLINUZ=/boot/efi/bzImage
INITRD=/boot/efi/initrd.img

kexec -l "$VMLINUZ" --initrd="$INITRD" --append="$CMDLINE"
systemctl kexec -i
