#!/bin/bash
source ./init.sh
source ./filemaker-installs/auto/.env

# Note this will close all databases are you sure you want to continue?
read -rep "WARNING: This will close all active databases! Write \"I understand\" if you want to continue!`echo $'\n> '`" choice
choiseLower=`echo "$choice" | tr '[:upper:]' '[:lower:]'` 
if [ "$choiseLower" != "i understand" ]; then
    echo "User aborted"
    exit 1
fi

# Close databases
docker exec -it $name$VERSION /install/shortcuts/fms-helper.sh down

# Stop docker
docker stop $name$VERSION