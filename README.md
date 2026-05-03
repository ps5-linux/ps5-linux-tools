# ps5-linux-tools

- `ps5_control.c`: Allows turning on/off fan and boost via `/dev/icc` and `/dev/mp1`.
- `systemd/ps5fan.service`: Starts fan control at boot by running `ps5_control --fan on`.
- `systemd/ps5boost.service`: Starts boost mode at boot by running `ps5_control --boost on`.
- `install.sh`: Builds `ps5_control`, installs the systemd services, and enables fan and boost at startup.
- `m2_init.c`: Creates a fake MBR header and GPT partition that makes PS5 OS happy.
- `m2_install.sh`: Installs a Linux `.img` file by formatting the M.2 as ext4 and copying files over.
- `m2_exec.sh`: Performs kexec into Linux on your M.2 SSD, or kexec reboots into the current system with `--reboot`.

## Systemd services

Install the binary and enable both services:

```sh
sudo ./install.sh
```

The installer places `ps5_control` at `/usr/local/sbin/ps5_control` and installs:

- `ps5fan.service`, which runs `/usr/local/sbin/ps5_control --fan on`
- `ps5boost.service`, which runs `/usr/local/sbin/ps5_control --boost on`

Disable either service if you do not want it at startup:

```sh
sudo systemctl disable --now ps5fan.service
sudo systemctl disable --now ps5boost.service
```

## Kexec reboot

If you are already booted from the M.2 system and want to kexec into your currently installed kernel:

```sh
sudo ./m2_exec.sh --reboot
```

This loads the current system's `/boot` kernel and initrd, reuses `/proc/cmdline`, and runs `systemctl kexec -i`.
