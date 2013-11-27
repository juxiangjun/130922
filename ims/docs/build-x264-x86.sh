#!/bin/sh

# This script is originally based off of the one by Gabriel Handford
# Original scripts can be found here: https://github.com/gabriel/ffmpeg-iphone-build
# Modified by Roderick Buenviaje
# Builds versions of the VideoLAN x264 for armv6 and armv7
# Combines the two libraries into a single one

trap exit ERR

export DIR=./x264
export DEST7S=x86_64/
#specify the version of iOS you want to build against
export VERSION="7.0"
export CFLAGS=""
export LDFLAGS=""
cd $DIR

echo "Building armv7..."
./configure --host=x86_64-apple-darwin \
--prefix=$DEST7S \
--enable-pic --enable-static \
--extra-cflags="-arch x86_64 " \
--extra-ldflags="-arch x86_64 " \
--disable-asm

make && make install

echo "Installed: $DEST7"
