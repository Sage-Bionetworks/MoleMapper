#!/bin/sh

#  Automatic build script for libssl and libcrypto 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 16.12.10.
#  Copyright 2010 Felix Schulze. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  Modified by Erin Mounts, Sage Bionetworks, Copyright 2015. Modifications
#  released under the same license.
#
###########################################################################
#  Change values here													  #
#                                                                         #
#VERSION="1.0.2c"													      #
SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`						  #
if [[ "${ENABLE_BITCODE}" == "YES" ]]; then
    if [[ "${BITCODE_GENERATION_MODE}" == "bitcode" ]]; then
        BITCODE_FLAG=" -fembed-bitcode"
    else
        BITCODE_FLAG=" -fembed-bitcode-marker"
    fi
    echo "Bitcode flag: ${BITCODE_FLAG}"
else
    BITCODE_FLAG=""
    echo "No bitcode flag"
fi

#																		  #
###########################################################################
#																		  #
# Don't change anything under this line!								  #
#																		  #
###########################################################################


CURRENTPATH=`pwd`
if [ ${CONFIGURATION} == Release ] ; then
    echo "Release build--excluding Simulator binaries"
    ARCHS="armv7 armv7s arm64"
else
    echo "Debug build--including Simulator binaries"
    ARCHS="i386 x86_64 armv7 armv7s arm64"
fi

DEVELOPER=`xcode-select -print-path`

if [ ! -d "$DEVELOPER" ]; then
  echo "xcode path is not set correctly $DEVELOPER does not exist (most likely because of xcode > 4.3)"
  echo "run"
  echo "sudo xcode-select -switch <xcode path>"
  echo "for default installation:"
  echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

case $DEVELOPER in  
     *\ * )
           echo "Your Xcode path contains whitespaces, which is not supported."
           exit 1
          ;;
esac

#case $CURRENTPATH in  
#     *\ * )
#           echo "Your path contains whitespaces, which is not supported by 'make install'."
#           exit 1
#          ;;
#esac

OUT_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}"
echo "Built products output directory: ${OUT_DIR}"
mkdir -p "${OUT_DIR}"

set -e
if [ ! -e openssl-${VERSION}.tar.gz ]; then
	echo "Downloading openssl-${VERSION}.tar.gz"
    curl -O https://www.openssl.org/source/openssl-${VERSION}.tar.gz
else
	echo "Using openssl-${VERSION}.tar.gz"
    if [ "${OUT_DIR}/libssl.a" -nt "openssl-${VERSION}.tar.gz" ]; then
        echo "Output files newer than input files, skipping"
        exit 0
    fi
fi

mkdir -p "${DERIVED_FILE_DIR}/src"
mkdir -p "${DERIVED_FILE_DIR}/bin"
mkdir -p "${DERIVED_FILE_DIR}/lib"

tar zxf openssl-${VERSION}.tar.gz -C "${DERIVED_FILE_DIR}/src"
cd "${DERIVED_FILE_DIR}/src/openssl-${VERSION}"

echo "Building openssl-${VERSION} for ${ARCHS}"

for ARCH in ${ARCHS}
do
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		PLATFORM="iPhoneSimulator"
	else
		sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
		PLATFORM="iPhoneOS"
	fi
	
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"

	echo "Building openssl-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
	echo "Please stand by..."

	export CC="${BUILD_TOOLS}/usr/bin/gcc -arch ${ARCH}"
	mkdir -p "${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	LOG="${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

	set +e
    if [[ "$VERSION" =~ 1.0.0. ]]; then
	    ./Configure BSD-generic32 --openssldir="${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1
	elif [ "${ARCH}" == "x86_64" ]; then
	    ./Configure darwin64-x86_64-cc --openssldir="${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1
    else
	    ./Configure iphoneos-cross --openssldir="${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1
    fi
    
    if [ $? != 0 ];
    then 
    	echo "Problem while configure - Please check ${LOG}"
    	exit 1
    fi

	# add -isysroot to CC=
	sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=7.0${BITCODE_FLAG} !" "Makefile"

    echo `grep ^CFLAG= Makefile`

	if [ "$1" == "verbose" ];
	then
		make
	else
		make >> "${LOG}" 2>&1
	fi
	
	if [ $? != 0 ];
    then 
    	echo "Problem while make - Please check ${LOG}"
    	exit 1
    fi
    
    set -e
	make install >> "${LOG}" 2>&1
	make clean >> "${LOG}" 2>&1

    echo "Adding results to libraries..."
    IN_LIB_DIR="${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib"
    if [ -e ${OUT_DIR}/libssl.a ]; then
        lipo -create ${IN_LIB_DIR}/libssl.a ${OUT_DIR}/libssl.a -output ${OUT_DIR}/libssl.a
    else
        lipo -create ${IN_LIB_DIR}/libssl.a -output ${OUT_DIR}/libssl.a
    fi
    if [ -e ${OUT_DIR}/libcrypto.a ]; then
        lipo -create ${IN_LIB_DIR}/libcrypto.a ${OUT_DIR}/libcrypto.a -output ${OUT_DIR}/libcrypto.a
    else
        lipo -create ${IN_LIB_DIR}/libcrypto.a -output ${OUT_DIR}/libcrypto.a
    fi

done

mkdir -p ${OUT_DIR}/include
if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
then
PLATFORM="iPhoneSimulator"
else
PLATFORM="iPhoneOS"
fi
cp -R ${DERIVED_FILE_DIR}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/include/openssl ${OUT_DIR}/include/

echo "Building done."
