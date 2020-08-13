#! /usr/bin/bash

# TODO: Move stuff to platform-specific file and/or use switchcase?

# Device specific
_platform=nile
_device=discovery
_board=sdm630

_verity_file=build/target/product/security/verity.x509.pem
_verity_key_id=$(openssl x509 -in $_verity_file -text | grep keyid | sed 's/://g' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/keyid//g')

# Image args
BOARD_KERNEL_BASE=0x00000000
BOARD_KERNEL_PAGESIZE=4096
BOARD_KERNEL_TAGS_OFFSET=0x01E00000
BOARD_RAMDISK_OFFSET=0x02000000
# lpm_levels.sleep_disabled=1 service_locator.enable=1
# BOARD_KERNEL_CMDLINE="buildvariant=userdebug veritykeyid=id:$_verity_key_id"

BOARD_KERNEL_CMDLINE+=" earlycon=msm_serial_dm,0xc170000 console=msm_serial_dm0"
# BOARD_KERNEL_CMDLINE+=" dm=\"system none ro,0 1 android-verity /dev/mmcblk0p78\""
BOARD_KERNEL_CMDLINE+=" dm-mod.create=\"dm-verity,,0,ro,
0 1638400 verity 1 /dev/mmcblk0p78 /dev/null 4096 4096 204800 1 sha1 $_verity_key_id\""
# TODO: Salt?

# Options
_permissive=true
_compiler=linaro_gcc
_recovery_ramdisk=false

_self_dir=$(realpath $(dirname "$0"))
. $_self_dir/compile.sh
