#!/usr/bin/env bash
#
# Copyright (C) 2020 CesiumOS project.
#
# Licensed under the General Public License.
# This program is free software; you can redistribute it and/or modify
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#
#

# Global variables
DEVICE="$1"
SYNC="$2"
CLEAN="$3"
CCACHE="$4"
JOBS="$(($(nproc --all)-4))"

function exports() {
   export CUSTOM_BUILD_TYPE=OFFICIAL
   export KBUILD_BUILD_HOST="NexusPenguin"
}

function sync() {
    # It's time to sync!
   git config --global user.name "SahilSonar"
   git config --global user.email "sss.sonar2003@gmail.com"
   echo "Syncing Source, will take Little Time."
   repo init --depth=1 -u git://github.com/CesiumOS/manifest.git -b ten
   repo sync -c -j"$JOBS" --no-tags --no-clone-bundle
   echo "Source Synced Successfully"
}

function use_ccache() {
    # CCACHE UMMM!!! Cooks my builds fast
   if [ "$CCACHE" = "true" ]; then
      echo "CCACHE is enabled for this build"
      export CCACHE_EXEC=$(which ccache)
      export USE_CCACHE=1
   fi
}

function clean_up() {
  # It's Clean Time
   if [ "$CLEAN" = "true" ]; then
      make clean && make clobber
   elif [ "$CLEAN" = "false" ]; then
      rm -rf out/target/product/*
      echo "OUT dir from your repo deleted"
    fi
}

function build_main() {
  # It's build time! YASS
    source build/envsetup.sh
    lunch cesium_${DEVICE}-userdebug
    mka bacon -j"$JOBS"
}

function build_end() {
  # It's upload time!
   if [ -f "out/target/product/$DEVICE/CesiumOS*.zip" ]; then
	  #JSON="CesiumOS*.json" not used for now
      rsync -azP  -e ssh out/target/product/"$DEVICE"/CesiumOS*.zip bunnyy@frs.sourceforge.net:/home/frs/project/cesiumos/"$DEVICE"/
      exit 0
   else
      exit 1
   fi
}

exports
if [ "$SYNC" = "true" ]; then
    sync
fi
use_ccache
clean_up
build_main
build_end
