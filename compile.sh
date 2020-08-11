#! /usr/bin/bash

set -e

for opt in "$@"; do
    case $opt in
        -f)
            FASTBOOT_FLASH=true
            echo "==> Option: Flashing images after build"
        ;;
    esac
done

# _kernel_major=4
# _kernel_minor=14

if [ -z "$ANDROID_BUILD_TOP" ]; then
    ANDROID_ROOT=$(realpath "$_self_dir/../")
    echo "WARNING: ANDROID_BUILD_TOP not set, guessing root at $ANDROID_ROOT"
else
    ANDROID_ROOT="$ANDROID_BUILD_TOP"
fi

_out=$ANDROID_ROOT/out/mainline-kernel
# $_compiler/$_device
_kernel=$_out/arch/arm64/boot/Image.gz-dtb
_make_vars="O=$_out ARCH=arm64 -j$(nproc)"
# _kernel_path=$(realpath $ANDROID_ROOT/kernel/sony/msm-$_kernel_major.$_kernel_minor/kernel)
_kernel_path=$(realpath $ANDROID_ROOT/kernel/mainline/kernel)
# True by default:
if [ "$_recovery_ramdisk" = "false" ]; then
    _ramdisk=$ANDROID_ROOT/out/target/product/$_device/ramdisk.img
else
    _ramdisk=$ANDROID_ROOT/out/target/product/$_device/ramdisk-recovery.img
fi
_boot_out=$_device-boot.img

if [ ! -f $_ramdisk ]; then
    echo "WARNING: $_ramdisk does not exist!"
fi

_targets=Image.gz

# if [ "$_has_dtbo" = "true" ]; then
_targets+=" dtbs"
#     _dtbo_out=$_device-dtbo.img
# fi

_self_dir=$(realpath $(dirname "$0"))
. $_self_dir/compile_$_compiler.sh

cat ${_kernel%-dtb} $_out/arch/arm64/boot/dts/qcom/$_board-sony-xperia-$_platform-$_device.dtb > $_kernel

. $_self_dir/create_images.sh

if [ "$FASTBOOT_FLASH" = "true" ]; then
    echo "==> Flashing $_boot_out"
    fastboot flash boot $_boot_out
    if [ "$_has_dtbo" = "true" ]; then
        echo "==> Flashing $_dtbo_out"
        fastboot flash dtbo $_dtbo_out
    fi

    echo "==> Rebooting device..."
    fastboot continue || fastboot reboot
fi
