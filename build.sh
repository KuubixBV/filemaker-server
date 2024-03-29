#!/bin/bash
source ./filemaker-installs/auto/.env
docker build -t fmsdocker:ubuntu22.04-v1 ./
sh ./run.sh

# Check if .env is loaded correctly
if [ ! -n "$name" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi
docker exec -it $name sh /install/auto/init.sh