#!/bin/bash
source ./filemaker-installs/auto/.env
source ./init.sh

# Check if .env is loaded correctly
if [ ! -n "$name" ] || [ ! -n "$hostname" ] || [ ! -n "$httpPort" ] || [ ! -n "$httpsPort" ] || [ ! -n "$filemakerVersionPath" ] || [ ! -n "$certificatePath" ] || [ ! -n "$filemakerAutoInstallerPath" ] || [ ! -n "$filemakerDataPath" ] || [ ! -n "$filemakerServerServicePath" ] || [ ! -n "$filemakerLicensePath" ] || [ ! -n "$japiPort" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Start the docker
docker run                                                                              \
 --detach                                                                               \
 --privileged                                                                           \
 --name $name$VERSION                                                                   \
 --hostname $hostname                                                                   \
 --publish 0.0.0.0:$xPort:"32582"                                                       \
 --publish 0.0.0.0:$httpPort:"80"                                                       \
 --publish 0.0.0.0:$httpsPort:"443"                                                     \
 --publish 0.0.0.0:$japiPort:"10073"                                                    \
 --publish 0.0.0.0:$pjBridgePort:"4444"                                                 \
 --publish 0.0.0.0:$filemakerPort:"5003"                                                \
 --volume $filemakerVersionPath:"/install"                                              \
 --volume $filemakerLicensePath:"/install/license"                                      \
 --volume $certificatePath:"/install/certificates"                                      \
 --volume $filemakerAutoInstallerPath:"/install/auto"                                   \
 --volume $filemakerSchedulePath:"/install/schedules"                                   \
 --volume $filemakerServerServicePath:"/install/shortcuts"                              \
 --volume $filemakerDataPath:"/opt/FileMaker/FileMaker Server/Data"                     \
 fmsdocker:ubuntu22.04-fms$VERSION                                                      

# Run init in docker
docker exec -it $name$VERSION /install/auto/init.sh