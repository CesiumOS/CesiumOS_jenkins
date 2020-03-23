#!/usr/bin/env bash
#
# Copyright (C) 2020 CesiumOS project.
#
# Licensed under the General Public License.
# This program is free software; you can redistribute it and/or modify
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#
#

# Haha yes some private keys 
password=$(cat /mnt/FILES/cred** | grep sf | cut -d "=" -f 2)

function sync()
{
   git config --global user.name "SahilSonar"
   git config --global user.email "sss.sonar2003@gmail.com"
   echo -e "Syncing Source, will take Little Time."
   repo init --depth=1 -u git://github.com/CesiumOS/manifest.git -b ten
   repo sync --force-sync -j20 --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune
   echo "Source Synced Successfully"
}

function use_ccache() {
    # CCACHE UMMM!!! Cooks my builds fast
   if [ "$use_ccache" = "true" ];
   then
      printf "CCACHE is enabled for this build"
      export CCACHE_EXEC=$(which ccache)
      export USE_CCACHE=1
}

function clean_up() {
  # Its Clean Time
   if [ "$make_clean" = "true" ]
   then
      make clean && make clobber
   elif [ "$make_clean" = "false" ]
   then
      rm -rf out/target/product/*
      wait
      echo -e "OUT dir from your repo deleted";
}

function build_main() {
    source build/envsetup.sh
    lunch cesium_${DEVICE}-userdebug
    make bacon -j20 
}

function build_end() {
   if [ -f /mnt/FILES/workspace/jenkins/workspace/cesium-$DEVICE/out/target/product/$DEVICE/CesiumOS*.zip ]
   then
      cd /mnt/FILES/workspace/jenkins/workspace/cesium-$DEVICE/out/target/product/$DEVICE
      ZIP=$(ls CesiumOS*.zip)
	  JSON="CesiumOS*.json"
	  status="passed"
          sshpass -p $password rsync -avP -e ssh CesiumOS*.zip bunnyy@frs.sourceforge.net:/home/frs/project/CesiumOS/$DEVICE
          upload_ftp
          exit 0
   else
      status="failed"
      exit 1
   fi
}

exports
sync
use_ccache
clean_up
build_main
build_end