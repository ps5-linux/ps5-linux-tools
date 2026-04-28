# ps5-linux-tools

- `ps5_control.c`: Allows turning on/off fan and boost via `/dev/icc` and `/dev/mp1`.
- `m2_init.c`: Creates a fake MBR header and GPT partition that makes PS5 OS happy.
- `m2_install.sh`: Installs a Linux `.img` file by formatting the M.2 as ext4 and copying files over.
- `m2_exec.sh`: Performs kexec into Linux on your M.2 SSD.
