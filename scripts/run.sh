#!/bin/bash
source ./filemaker-installs/auto/.env
source ./filemaker-installs/current/version.sh

# Check if .env is loaded correctly
if [ ! -n "$NAME" ] || [ ! -n "$HOSTNAME" ] || [ ! -n "$HTTPS_PORT" ] || [ ! -n "$FM_CERTIFICATE_PATH" ] || [ ! -n "$FM_DATA_PATH" ] || [ ! -n "$FM_LICENSE_PATH" ] || [ ! -n "$JAPI_PORT" ] || [ ! -n "$FM_PORT" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Start the docker
docker run                                                                              \
 --detach                                                                               \
 --privileged                                                                           \
 --name $NAME$VERSION                                                                   \
 --hostname $HOSTNAME                                                                   \
 --publish $X_PORT:"32582"                                                              \
 --publish $FM_PORT:"5003"                                                              \
 --publish $HTTPS_PORT:"443"                                                            \
 --publish $JAPI_PORT:"10073"                                                           \
 --volume $FM_LICENSE_PATH:"/install/license"                                           \
 --volume $FM_SCHEDULE_PATH:"/install/schedules"                                        \
 --volume "./filemaker-utils":"/install/shortcuts"                                      \
 --volume "./filemaker-installs/current":"/install"                                     \
 --volume "./filemaker-installs/auto":"/install/auto"                                   \
 --volume $FM_CERTIFICATE_PATH:"/install/certificates"                                  \
 --volume $FM_DATA_PATH:"/opt/FileMaker/FileMaker Server/Data"                          \
 fmsdocker:ubuntu22.04-fms$VERSION                                                      

# Run init in docker
docker exec -it $NAME$VERSION /install/auto/init.sh