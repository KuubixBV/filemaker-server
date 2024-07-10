#!/usr/bin/env bash
# This is a template that will be used by generate.sh - DO NOT CHANGE THIS FILE!

# Location of system certificates - make sure files exists and are called cert.pem, privkey.pem and fullchain.pem
CERT_SYSTEM=

# Location of docker container certificates
CERT_DOCKER=

# Email to and from + enable
TO=
FROM=
ENABLE_EMAIL=

# Copy certs to filemaker using fmsadmin
echo "Copying certificates to FileMaker Server"
cp $CERT_SYSTEM/cert.pem $CERT_DOCKER/cert.pem
cp $CERT_SYSTEM/privkey.pem $CERT_DOCKER/privkey.pem
cp $CERT_SYSTEM/fullchain.pem $CERT_DOCKER/fullchain.pem

# Change owner to fmserver (999 in docker container) with group fmsadmin (1000 in docker container)
chown 999:1000 $CERT_DOCKER/cert.pem $CERT_DOCKER/privkey.pem $CERT_DOCKER/fullchain.pem

# Mail notification for restarting FileMaker Server
if [ "$ENABLE_EMAIL" = true ]; then
echo "Copied over new certificates for server. Please make sure nobody is working in one of the hosted databases before executing the following tasks! First import these certificates into the FileMaker Server by running option 'Import SSL certificates' in manager.sh. Next run 'Stop all FileMaker databases'. Next run 'Stop Docker container' followed by 'Start Docker container'. After these steps the certificates should be installed. Make sure to validate the result." | mail -s "Server: $FQDN | Certificates copied - import and restart needed" $TO -a "FROM:$FROM"
fi