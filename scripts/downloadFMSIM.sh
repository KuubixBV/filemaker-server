#!/bin/bash
source ./filemaker-installs/auto/.env
source ./versions.sh

# Check if .env is loaded correctly
if [ -z "$NAME" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Check if .version is loaded correctly
if [ -z "$OLD" ] || [ -z "$NEW" ] || [ -z "$STABLE" ]; then
   echo "Could not load needed data... Do you have a .version file? Are you missing key-values?"
   exit 1
fi

# Check what version to install and run
if [ "$1" == "old" ]; then
   version=$OLD
   location=$OLD_LOCATION
   echo "Selected old version '$version'..."
elif [ "$1" == "new" ]; then
   version=$NEW
   location=$NEW_LOCATION
   echo "Selected new version '$version'..."
elif [ "$1" == "stable" ]; then
   version=$STABLE
   location=$STABLE_LOCATION
   echo "Selected stable version '$version'..."
elif [ "$1" == "specific" ]; then
   version=$2
   location=$3
   echo "Selected specific version '$version'..."
else
   echo "No version specified. Please use {old|new|stable|specific}"
   exit 1
fi

# Check if filemaker version is installed
installPath="./filemaker-installs/versions/$version"
if [ ! -f "$installPath/fms-installer.deb" ] ; then

   # Create path and download zip
   echo "Filemaker not found, trying to download/unzip filemaker using version number $version @ $location"
   mkdir -p $installPath;

   # Check if zip exists
   if [ ! -f "$installPath/fms-installer.zip" ] ; then
      wget -O $installPath/fms-installer.zip $location
   else
      printf 'We found the fms-installer.zip. Do you want to re-download the zip (y/n)? '
      read redownload
      if [ "$redownload" != "${redownload#[Yy]}" ] ;then 
         wget -O $installPath/fms-installer.zip $location
      fi
   fi
   
   # Check if zip is ready to be unzipped
   if [ -f "$installPath/fms-installer.zip" ]; then
      unzip -o $installPath/fms-installer.zip -d $installPath/
   else
      echo "Could not download the filemaker server @ $location Please make sure this is a valid URL"
   fi

   # Count the number of .deb files in the directory
   debFilesCount=$(find "$installPath" -maxdepth 1 -type f -name "*.deb" | wc -l)

   # Check if there is exactly one .deb file
   if [ "$debFilesCount" -eq 1 ]; then
      # Find the .deb file and rename it to fms-installer.deb
      for file in "$installPath"/*.deb; do
         mv "$file" "$installPath/fms-installer.deb"
         break # Break after the first iteration, just in case, but there should only be one file
      done
   elif [ "$debFilesCount" -gt 1 ]; then
      echo "Error: More than one .deb file found. Please ensure only one .deb file is present."
      exit 1
   else
      echo "No .deb files found."
      exit 1
   fi
fi

# Check for fms-installer.deb
if [ ! -f "$installPath/fms-installer.deb" ]; then
     echo "Could not get the fms-installer.deb from the installer..."
     exit 1
fi

# Copy over fms-installer.deb to /current/fms-installer.deb
mkdir -p "./filemaker-installs/current";
cp "$installPath/fms-installer.deb" "./filemaker-installs/current/fms-installer.deb"
echo "VERSION=$version" > "./filemaker-installs/current/version.sh"

# Warn user to rebuild
echo "Current version has changed to $version"
echo "Please rebuild after changing versions. Please note to review the .env file - changes may be needed - be aware of port-collisions and mount-collisions!!!"