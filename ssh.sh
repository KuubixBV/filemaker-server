#!/bin/bash
source ./filemaker-installs/auto/.env
source ./init.sh

# Run bash in docker
docker exec -it $name$VERSION /bin/bash