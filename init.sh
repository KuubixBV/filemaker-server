#!/bin/bash
source ./filemaker-installs/current/version.sh

# Check if version.sh is loaded correctly
if [ ! -n "$VERSION" ] ; then
   echo "\n\nNo FMS version has been found. Please run "bash changeFMSVersion.sh stable" before building the docker image."
   exit 1
fi