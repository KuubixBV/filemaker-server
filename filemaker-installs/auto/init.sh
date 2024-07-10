#!/bin/bash

# Function to handle SIGTERM
#shutdown() {
#   /install/shortcuts/shutdown.sh
#}

# Trap SIGTERM
#trap shutdown SIGTERM

# Check if file exists
if [ -f ".initCompleted" ] ; then 
   echo "Init has already run..."
   exit 0
fi

. /install/auto/.env

# Check if .env is loaded correctly
if [ ! -n "$FM_USERNAME" ] || [ ! -n "$FM_PASSWORD" ] || [ ! -n "$FM_PIN" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Stop firewall -- THIS SHIT THING HAS MADE YENTL AND ME CRY! - NUKED IT! THIS SHOULD BE EXECUTED FIRST
echo "<--- FIREWALL DISABLED --->"
service systemd-logind start
systemctl disable firewalld.service
systemctl stop firewalld.service
systemctl mask --now firewalld
echo "<--- FIREWALL DISABLED --->"

# Stop apache before installing FileMaker Server
systemctl enable apache2
systemctl stop apache2

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

Admin Console User=$FM_USERNAME

Admin Console Password=$FM_PASSWORD

Admin Console PIN=$FM_PIN

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
sed -i~ "/^JDBC_HOST=/s/=.*/=\"localhost\"/" .env
sed -i~ "/^JDBC_PORT=/s/=.*/=\"4444\"/" .env
sed -i~ "/^JDBC_USER=/s/=.*/=\"$JDBC_USERNAME\"/" .env
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

# Create check_apache.sh script
echo "#!/bin/bash
if ! pgrep apache2 > /dev/null
then
    /usr/sbin/apache2ctl -D FOREGROUND
fi
" > /usr/local/bin/check_apache.sh

chmod +x /usr/local/bin/check_apache.sh

# Create the systemd service for check_apache.sh
echo "[Unit]
Description=Apache2 Health Check
[Service]
ExecStart=/usr/local/bin/check_apache.sh
Restart=always
User=root
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/check_apache.service

# Start all daemons
systemctl daemon-reload
systemctl enable jdbc
systemctl start jdbc

# Enable and start the apache check service
systemctl enable check_apache.service
systemctl start check_apache.service

# Install alias

## fmsadmin
echo "alias fmsadmin-up='fmsadmin start adminserver'" >> /root/.bashrc
echo "alias fmsadmin-down='fmsadmin stop adminserver'" >> /root/.bashrc
echo "alias fmsadmin-restart='fmsadmin restart adminserver'" >> /root/.bashrc

## jdbc
echo "alias jdbc-up='sh /opt/FileMaker/JDBC/jdbc.sh up'" >> /root/.bashrc
echo "alias jdbc-down='sh /opt/FileMaker/JDBC/jdbc.sh down'" >> /root/.bashrc
echo "alias jdbc-restart='sh /opt/FileMaker/JDBC/jdbc.sh down && sh /opt/FileMaker/JDBC/jdbc.sh up'" >> /root/.bashrc

# Setup admin console to enable JDBC/ODBC
python3 /install/auto/setupAdminConsole.py

# Install certificates using script (will abort if not available)
echo "Trying to install certificates if any"
. /install/auto/.env
certificatePath="/install/certificates"

# Check if folder exists
install=true
if [ -d "$certificatePath" ]; then
   echo "$certificatePath is not a directory. Cannot find certificate files."
   install=false
fi

# Check if needed files are present
if [ $install && ! -f "$certificatePath/cert.pem" ] || [ ! -f "$certificatePath/privkey.pem" ] || [ ! -f "$certificatePath/fullchain.pem" ]; then
   echo "Not all files are present: $certificatePath/cert.pem, $certificatePath/privkey.pem and $certificatePath/fullchain.pem should all be present."
   install=false
fi

# Import certificate if install is true
if $install; then
   fmsadmin certificate import "$certificatePath/cert.pem" --keyfile "$certificatePath/privkey.pem" --intermediateCA "$certificatePath/fullchain.pem" -u "$FM_USERNAME" -p "$FM_PASSWORD" -y
   echo "Restart of docker container needed before certificates are valid! Please do this manually using manager.sh!"
fi

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

# Create new file so we know this init has run
touch .initCompleted