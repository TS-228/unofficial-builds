#!/bin/bash -xe

__dirname=$1
fullversion=$2

. ${__dirname}/_decode_version.sh

decode "$fullversion"

# Build for v24 and newer — official armv7l binaries were dropped starting v24
test "$major" -ge "24"
