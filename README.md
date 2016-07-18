# BUILDING

## U-BOOT
```
# Build Device Tree Compiler
cd dtc
make

# Build U-Boot
cd u-boot-sunxi
export PATH=../dtc/:$PATH
make ARCH=arm -j6 CROSS_COMPILE=arm-linux-gnueabi- orangepi_pc_defconfig
make ARCH=arm -j6 CROSS_COMPILE=arm-linux-gnueabi-
```

## Buildroot
```
cd buildroot/
ln -s ../configs/buildroot.config .config
make ARCH=arm -j6 CROSS_COMPILE=arm-linux-gnueabi-
```

## Sunxi-tools
We need sunxi-fel tool to use FEL mode
```
cd sunxi-tools/
make
```

## Kernel
```
cd linux/
cp ../configs/kernel.config .config
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- oldconfig
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- LOADADDR=0x40008000 uImage dtbs
```

# INSTALLING

## U-Boot on SD card
```
CARDPATH=/dev/sdd
cd u-boot-sunxi
dd if=u-boot-sunxi-with-spl.bin of=${CARDPATH} bs=1024 seek=8
```

## SD card that will automatically enter FEL mode on boot:
```
CARDPATH=/dev/sdd
dd if=bin/fel-sdboot.sunxi of=${CARDPATH} bs=1024 seek=8
```

# USAGE

## Booting without SD card
If no SD card is detected, the board will automatically enter FEL mode. You can then boot the system using:
```

./BOOT.sh
```

This will upload u-boot, kernel and initramfs to the board and then boot it. The process is little slow as
it takes about 11 seconds to transfer all the files to the board with the buildroot initramfs.

## Booting with SD card
In order to use fullblown linux system for testing, its better to use filesystem on SD card. Just install any
image you want to use to the SD card, then write `fel-sdboot.sunxi` to it and run:

```
./BOOT.sh sd
```

This will transfer required files much faster (about 5 seconds) as initramfs is not required.
