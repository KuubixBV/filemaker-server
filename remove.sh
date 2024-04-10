#!/bin/bash
source ./init.sh
source ./filemaker-installs/auto/.env

# Remove the docker file
bash ./stop.sh
docker remove $name$VERSION