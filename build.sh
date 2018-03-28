#!/bin/bash

export ARCH=arm64

ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/out
BUILDING_DIR=$OUT_DIR/kernel_obj

JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
DATE=`date +%m-%d-%H:%M`

ZIP_DIR=$ROOT_DIR/zip
TEMP_DIR=$OUT_DIR/temp

# Color Codes
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Tweakable options
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="PaLoDa"
export KBUILD_BUILD_HOST="LsDtY"
export CROSS_COMPILE=/home/paloda/cocina/aarch64-cortex_a53-linux-gnueabi-gcc-7/bin/aarch64-cortex_a53-linux-gnueabi-
DEFCONFIG=mido_defconfig

# Compilation Scripts Are Below

FUNC_PRINT()
{
echo -e "$Cyan***********************************************"
echo "         Compiling PaLoDa Kernel             "
echo -e "***********************************************$nocol"
}

FUNC_COMPILE_KERNEL()
{
		FUNC_PRINT "Start Compiling Kernel"
		make -C $ROOT_DIR O=$BUILDING_DIR $DEFCONFIG 
		make -C $ROOT_DIR O=$BUILDING_DIR -j$JOB_NUMBER
		FUNC_PRINT "Finish Compiling Kernel"
}

FUNC_CLEAN()

{
		FUNC_PRINT "Cleaning All"
		rm -rf $OUT_DIR
		mkdir $OUT_DIR
		mkdir -p $BUILDING_DIR
		mkdir -p $TEMP_DIR
}

FUNC_PACK()
{
		FUNC_PRINT "Start Packing"
		cp -r $ZIP_DIR/* $TEMP_DIR
		cp $BUILDING_DIR/arch/arm64/boot/Image.gz-dtb $TEMP_DIR/zImage-dtb
        mkdir $TEMP_DIR/modules
        find . -type f -name "wlan.ko" | xargs cp -t $TEMP_DIR/modules
        find $TEMP_DIR -iname "wlan.ko" -exec /home/paloda/cocina/aarch64-cortex_a53-linux-gnueabi-gcc-7/bin/aarch64-cortex_a53-linux-gnueabi-strip- --strip-debug {} \;
		cd $TEMP_DIR
		zip -r9 PaLoDa-v1.5.zip ./*
		mv palodakernel.zip $OUT_DIR/palodakernel-$DATE.zip
		cd $ROOT_DIR
		FUNC_PRINT "$Green Finish Packing $nocol"
}

START_TIME=`date +%s`
FUNC_CLEAN
FUNC_COMPILE_KERNEL
FUNC_PACK
END_TIME=`date +%s`

echo -e "$Yellow***********************************************"
echo "let ELAPSED_TIME=$END_TIME-$START_TIME         "
echo "Total compile time is $ELAPSED_TIME minutes"
echo -e "***********************************************$nocol"
