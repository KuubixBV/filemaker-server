#!/bin/bash

# Function to handle SIGTERM
#shutdown() {
#   /install/shortcuts/shutdown.sh
#}

# Trap SIGTERM
#trap shutdown SIGTERM

# Setting timezone
timedatectl set-timezone "Europe/Brussels"

# Check if file exists
if [ -f ".initCompleted" ] ; then 
   echo "Init has already ran..."
   exit 0
fi
. /install/auto/.env

# Check if .env is loaded correctly
if [ ! -n "$filemakerUsername" ] || [ ! -n "$filemakerPassword" ] || [ ! -n "$filemakerPincode" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Stop apache before installing FileMaker Server
systemctl stop apache2

# Stop firewall -- THIS SHIT THING HAS MADE YENTL AND ME CRY! - NUKED IT!
systemctl disable firewalld.service
systemctl stop firewalld.service
systemctl mask ---now firewalld

# Check if "Assisted Install.txt" exists. If so rename file to .bak
assistedInstallFile="/install/Assisted Install.txt"
if [ -f "$assistedInstallFile" ]; then
   mv "$assistedInstallFile" "$assistedInstallFile.bak"
fi

# Check if license file exists
echo "Trying to check for valid license if any"
licensePath="/install/license/"
licenseFile=$(find "$licensePath" -maxdepth 1 -name "*.fmcert" | head -n 1)

# Check if a file was found
if [ -n "$licenseFile" ]; then 
   echo "Found license @ $licenseFile"
else
   licenseFile=""
   echo "No license file found @ $licensePath"
fi

# Create new "Assisted Install.txt"
echo "[Assisted Install]

License Accepted=1

Deployment Options=0

Admin Console User=$filemakerUsername

Admin Console Password=$filemakerPassword

Admin Console PIN=$filemakerPincode

License Certificate Path=$licenseFile

Filter Databases=0

Remove Desktop Shortcut=0

Remove Sample Database=1" > "$assistedInstallFile"

# Install filemaker
export FM_ASSISTED_INSTALL=/install
apt install /install/fms-installer.deb -y -y

# Get PJBridge for using JDBC connection
cd /opt/FileMaker/
mkdir JDBC
git clone https://github.com/KuubixBV/php-claris-jdbc-bridge.git /opt/FileMaker/JDBC/

# Get JDBC-API
cd /var/www/
mkdir japi.mastermeubel.be
git clone https://github.com/KuubixBV/filemaker-jdbc-api.git /var/www/japi.mastermeubel.be/
cd /var/www/japi.mastermeubel.be/
composer install
chown -R $USER:www-data storage
chown -R $USER:www-data bootstrap/cache
chmod -R 775 storage
chmod -R 775 bootstrap/cache
cp .env.example .env
sed -i~ "/^JDBC_HOST=/s/=.*/=\"$JDBC_HOST\"/" .env
sed -i~ "/^JDBC_PORT=/s/=.*/=\"$JDBC_PORT\"/" .env
sed -i~ "/^JDBC_USER=/s/=.*/=\"$JDBC_USER\"/" .env
sed -i~ "/^JDBC_PASSWORD=/s/=.*/=\"$JDBC_PASSWORD\"/" .env
sed -i~ "/^JDBC_DATABASE=/s/=.*/=\"$JDBC_DATABASE\"/" .env

# Creating daemons

## Daemon 1 - JDBC bridge
echo "[Unit]
Description=The JDBC service for Claris FileMaker
[Service]
User=root
WorkingDirectory=/opt/FileMaker/JDBC/
ExecStart=/opt/FileMaker/JDBC/jdbc.sh up
ExecStop=/opt/FileMaker/JDBC/jdbc.sh down
Type=forking
TimeoutStopSec=10
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
" > "/etc/systemd/system/jdbc.service"

## Start all daemons
systemctl daemon-reload
systemctl enable jdbc
systemctl start jdbc

# Install alias

## fms
echo "alias fms-up='sh /install/shortcuts/fms-helper.sh up'" >> /root/.bashrc
echo "alias fms-down='sh /install/shortcuts/fms-helper.sh down'" >> /root/.bashrc
echo "alias fms-restart='sh /install/shortcuts/fms-helper.sh down && sh /install/shortcuts/fms-helper.sh up'" >> /root/.bashrc
echo "alias fms-install-certificates='sh /install/shortcuts/fms-helper.sh install-certificates'" >> /root/.bashrc

## fmsadmin
echo "alias fmsadmin-up='fmsadmin start adminserver'" >> /root/.bashrc
echo "alias fmsadmin-down='fmsadmin stop adminserver'" >> /root/.bashrc
echo "alias fmsadmin-restart='fmsadmin restart adminserver'" >> /root/.bashrc

## jdbc
echo "alias jdbc-up='sh /opt/FileMaker/JDBC/jdbc.sh up'" >> /root/.bashrc
echo "alias jdbc-down='sh /opt/FileMaker/JDBC/jdbc.sh down'" >> /root/.bashrc
echo "alias jdbc-restart='sh /opt/FileMaker/JDBC/jdbc.sh down && sh /opt/FileMaker/JDBC/jdbc.sh up'" >> /root/.bashrc

## all
echo "alias all-up='fms-up && fmsadmin-up && jdbc-up'" >> /root/.bashrc
echo "alias all-down='fms-down && fmsadmin-down && jdbc-down'" >> /root/.bashrc
echo "alias all-restart='fms-down && fmsadmin-down && jdbc-down && fms-up && fmsadmin-up && jdbc-up'" >> /root/.bashrc

# Setup admin console to enable JDBC/ODBC
python3 /install/auto/setupAdminConsole.py

# Install certificates using script (will fail if not available)
echo "Trying to install certificates if any"
bash /install/shortcuts/fms-helper.sh install-certificates restart force

# Change apache config for japi
echo "<VirtualHost *:10073>
   ServerName localhost
   DocumentRoot /var/www/japi.mastermeubel.be/public/
   <Directory /var/www/japi.mastermeubel.be/>
       AllowOverride All
   </Directory>
   <Directory /var/www/japi.mastermeubel.be/public/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > "/etc/apache2/sites-available/japi.mastermeubel.be.conf"
echo "Listen 10073" > "/etc/apache2/ports.conf"

a2enmod rewrite
a2dissite 000-default.conf
a2ensite japi.mastermeubel.be
systemctl start apache2

# Create new file so we know this init has ran
touch .initCompleted