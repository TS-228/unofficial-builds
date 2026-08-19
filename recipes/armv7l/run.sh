#!/usr/bin/env bash

set -e
set -x

release_urlbase="$1"
disttype="$2"
customtag="$3"
datestring="$4"
commit="$5"
fullversion="$6"
source_url="$7"
source_urlbase="$8"
config_flags=

cd /home/node

tar -xf node.tar.xz

cd "node-${fullversion}"

export CCACHE_BASEDIR="$PWD"
export CC_host="ccache gcc-14 -m32"
export CXX_host="ccache g++-14 -m32"
export CC="ccache arm-linux-gnueabihf-gcc-14 -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard"
export CXX="ccache arm-linux-gnueabihf-g++-14 -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard"

make -j$(getconf _NPROCESSORS_ONLN) binary V= \
  DESTCPU="arm" \
  ARCH="armv7l" \
  VARIATION="" \
  DISTTYPE="$disttype" \
  CUSTOMTAG="$customtag" \
  DATESTRING="$datestring" \
  COMMIT="$commit" \
  RELEASE_URLBASE="$release_urlbase" \
  CONFIG_FLAGS="$config_flags"

mv node-*.tar.?z /out/
