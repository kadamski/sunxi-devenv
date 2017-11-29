#!/bin/bash
UBOOTDIR=./u-boot-sunxi
KERNELDIR=./linux
SUNXITOOLSDIR=./sunxi-tools
TMPDIR=./tmp
INITRAMFS=./buildroot/output/images/rootfs.cpio.uboot

declare -A DTBS
DTBS[opi_pc]=sun8i-h3-orangepi-pc.dtb
DTBS[npi_neo]=sun8i-h3-nanopi-neo.dtb

BOARD=${BOARD:-opi_pc}

if [ -z "${DTBS[${BOARD}]}" ]; then
	echo "Wrong BOARD env"
	exit 1
else
	echo "*** Using ${DTBS[${BOARD}]} u-boot defconfig"
fi

KERNEL_ADDR=0x42000000
RAMDISK_ADDR=0x43300000
FDT_ADDR=0x43000000
SCRIPT_ADDR=0x43100000
RAMDISKCMD=""

if [ "$1" == "sd" ]; then
    RAMDISK_ADDR=-
else
    RAMDISKCMD="write ${RAMDISK_ADDR} ${INITRAMFS}"
fi

mkdir -p ${TMPDIR}
cat << _END_ > ${TMPDIR}/bootcmd_fel.txt
setenv fdt_high ffffffff
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait
setenv bootdelay 5
bootm $KERNEL_ADDR $RAMDISK_ADDR $FDT_ADDR
_END_

mkimage -C none -A arm -T script -d ${TMPDIR}/bootcmd_fel.txt ${TMPDIR}/bootfel.scr

${SUNXITOOLSDIR}/sunxi-fel uboot ${UBOOTDIR}/u-boot-sunxi-with-spl.bin \
 write ${KERNEL_ADDR} ${KERNELDIR}/arch/arm/boot/uImage \
 write ${FDT_ADDR} ${KERNELDIR}/arch/arm/boot/dts/${DTBS[$BOARD]} \
 write ${SCRIPT_ADDR} ${TMPDIR}/bootfel.scr \
 ${RAMDISKCMD}
