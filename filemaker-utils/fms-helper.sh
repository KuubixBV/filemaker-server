#!/bin/bash
. /install/auto/.env

certificatePath="/install/certificates"
case "$1" in
    up)
        service fmshelper start &
        ;;
    down)
        fmsadmin close -u "$filemakerUsername" -p "$filemakerPassword" -y
        service fmshelper stop &
        ;;
    install-certificates)
        # Check if folder exists
        if [ ! -d "$certificatePath" ]; then
            echo "$certificatePath is not a directory. Cannot find certificate files."
            exit 1
        fi

        # Check if needed files are present
        if [ ! -f "$certificatePath/cert.pem" ] || [ ! -f "$certificatePath/privkey.pem" ] || [ ! -f "$certificatePath/fullchain.pem" ]; then
            echo "Not all files are present: $certificatePath/cert.pem, $certificatePath/privkey.pem and $certificatePath/fullchain.pem should all be present."
            exit 1
        fi

        # Import certificate
        fmsadmin certificate import "$certificatePath/cert.pem" --keyfile "$certificatePath/privkey.pem" --intermediateCA "$certificatePath/fullchain.pem" -u "$filemakerUsername" -p "$filemakerPassword" -y
        if [ "$2" = "restart" ]; then

            if [ "$3" != "force" ]; then
                # Note this will close all databases are you sure you want to continue?
                read -rp "WARNING: This will close all active databases! Write \"I understand\" if you want to continue!`echo $'\n> '`" choice
                choiseLower=`echo "$choice" | tr '[:upper:]' '[:lower:]'` 
                if [ "$choiseLower" != "i understand" ]; then
                    echo "User aborted - manual restart needed to apply the certs."
                    exit 1
                fi
            fi
            bash ./install/shortcuts/fms-helper.sh down
            bash ./install/shortcuts/fms-helper.sh up
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|install-certificates [restart:optional]}"
        ;;
esac