# ps5-linux-tools

- `ps5_control.c`: Allows turning on/off fan and boost via `/dev/icc` and `/dev/mp1`.
- `systemd/ps5fan.service`: Starts fan control at boot by running `ps5_control --fan on`.
- `systemd/ps5boost.service`: Starts boost mode at boot by running `ps5_control --boost on`.
- `install.sh`: Builds `ps5_control`, installs the systemd services, and enables fan and boost at startup.
- `m2_init.c`: Creates a fake MBR header and GPT partition that makes PS5 OS happy.
- `m2_install.sh`: Installs a Linux `.img` file by formatting the M.2 as ext4 and copying files over.
- `m2_exec.sh`: Performs kexec into Linux on your M.2 SSD.
- `ps5-linux-warm-reboot.sh`: Performs a fast kexec reboot into Linux.

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
