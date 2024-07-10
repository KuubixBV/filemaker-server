#!/bin/bash
source ./filemaker-installs/auto/.env
source ./versions.sh

# Check what version to set
if [ "$1" == "old" ]; then
   version=$OLD
   echo "Selected old version '$version'..."
elif [ "$1" == "new" ]; then
   version=$NEW
   echo "Selected new version '$version'..."
elif [ "$1" == "stable" ]; then
   version=$STABLE
   echo "Selected stable version '$version'..."
elif [ "$1" == "specific" ]; then
   version=$2
   echo "Selected specific version '$version'..."
else
   echo "No version specified. Please use {old|new|stable|specific}"
   exit 1
fi

# Check for fms-installer.deb
installPath="./filemaker-installs/versions/$version"
if [ ! -f "$installPath/fms-installer.deb" ]; then
     echo "Could not get the fms-installer.deb from the installer... Are you sure this version is downloaded?"
     exit 1
fi

# Copy over fms-installer.deb to /current/fms-installer.deb
mkdir -p "./filemaker-installs/current";
cp "$installPath/fms-installer.deb" "./filemaker-installs/current/fms-installer.deb"
echo "VERSION=$version" > "./filemaker-installs/current/version.sh"

# Warn user to rebuild
echo "Current version has changed to $version"
echo "Please rebuild after changing versions. Please note to review the .env file - changes may be needed - be aware of port-collisions and mount-collisions!"