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

        # Check if process is started
        if [ -f "$PIDFILE" ]; then
            fmsadmin certificate import "$certificatePath/cert.pem" --keyfile "$certificatePath/privkey.pem" --intermediateCA "$certificatePath/fullchain.pem" -u "$filemakerUsername" -p "$filemakerPassword" -y
            echo "Certificates installed. Manual fms-restart needed"
        else
            echo "$SERVICE_NAME is not running."
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|install-certificates}"
        ;;
esac