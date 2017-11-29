#!/bin/sh
set -e
CROSSCOMPILER=arm-linux-gnu-

declare -A UBOOT_DEF
UBOOT_DEF[opi_pc]=orangepi_pc_defconfig
UBOOT_DEF[npi_neo]=nanopi_neo_defconfig

BOARD=${BOARD:-opi_pc}

if [ -z "${UBOOT_DEF[${BOARD}]}" ]; then
	echo "Wrong BOARD env"
	exit 1
else
	echo "*** Using ${UBOOT_DEF[${BOARD}]} u-boot defconfig"
fi

pushd dtc
make
popd

pushd sunxi-tools
make
popd

pushd u-boot-sunxi/
export PATH=../dtc/:$PATH
if [ ! -f .config ]; then
	make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER} ${UBOOT_DEF[$BOARD]}
fi
make ARCH=arm -j6 CROSS_COMPILE=${CROSSCOMPILER}
popd

pushd linux
if [ ! -f .config ]; then
	cp ../configs/kernel.defconfig arch/arm/configs/custom_defconfig
	make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER} custom_defconfig
fi
make -j4 ARCH=arm CROSS_COMPILE=${CROSSCOMPILER} LOADADDR=0x40008000 uImage dtbs
popd

for km in kernel-modules/*; do
	pushd ${km}
	make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER}
	make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER} INSTALL_MOD_PATH=../buildroot-overlay/ install
	popd
done

pushd buildroot
if [ ! -f .config ]; then
	cp ../configs/buildroot.defconfig configs/custom_defconfig
	make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER} custom_defconfig
fi
make ARCH=arm CROSS_COMPILE=${CROSSCOMPILER}
popd
