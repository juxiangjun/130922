#!/bin/sh

# This script is originally based off of the one by Gabriel Handford
# Original scripts can be found here: https://github.com/gabriel/ffmpeg-iphone-build
# Modified by Roderick Buenviaje
# Builds versions of the VideoLAN x264 for armv6 and armv7
# Combines the two libraries into a single one

trap exit ERR

export DIR=./x264
export DEST7S=arm64/
#specify the version of iOS you want to build against
export VERSION="7.0"


cd $DIR

echo "Building armv7..."
./configure --host=arm-apple-darwin \
--sysroot="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk" \
--prefix=$DEST7S \
--extra-cflags="-arch arm64 -mfpu=neon -miphoneos-version-min=6.1" \
--extra-ldflags="-arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk -miphoneos-version-min=6.1" \
--enable-pic --enable-static \
--disable-asm

make && make install

echo "Installed: $DEST7"
