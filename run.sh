#!/bin/bash
source ./filemaker-installs/auto/.env

# Check if .env is loaded correctly
if [ ! -n "$name" ] || [ ! -n "$hostname" ] || [ ! -n "$httpPort" ] || [ ! -n "$httpsPort" ] || [ ! -n "$filemakerInstallPath" ] || [ ! -n "$certificatePath" ] || [ ! -n "$filemakerAutoInstallerPath" ] || [ ! -n "$filemakerDataPath" ] || [ ! -n "$filemakerServerServicePath" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

docker run                                                                              \
 --detach                                                                               \
 --privileged                                                                           \
 --name $name                                                                           \
 --hostname $hostname                                                                   \
 --publish $httpPort:80                                                                 \
 --publish $httpsPort:443                                                               \
 --publish $pjBridgePort:4444                                                           \
 --publish $filemakerPort:5003                                                          \
 --volume $filemakerInstallPath:/install/                                               \
 --volume $certificatePath:/install/certificates/                                       \
 --volume $filemakerAutoInstallerPath:/install/auto/                                    \
 --volume $filemakerDataPath:"/opt/FileMaker/FileMaker Server/Data/"                    \
 --volume $filemakerServerServicePath:"/install/shortcuts/" fmsdocker:ubuntu22.04-v1