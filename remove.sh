#!/bin/bash
source ./init.sh
source ./filemaker-installs/auto/.env

# Remove the docker file
docker remove $name$VERSION