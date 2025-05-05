Indy verwijderd eens privileged uit run file voor testen! Ask Yentl if u are confused why we needed to try this!
# How to use this delicate piece of software

Since I never want to redo any of this in my life, I suppose I need some documentation for future me. If you are reading this - you are in for a ride!

## 1. Setup

First we need to have to download the .deb FileMaker installation. I made this process easy by adding a script so you won't have to do anything but to call it. Before we do so, we want to create an environment file that will store all the secrets of our installation. We will also set some other values that will be used during the installation of the FileMaker package.

### A. Setting up the .env file

First navigate to the folder `/filemaker-installs/auto`. Here you can copy over the `.env.example` to a new file called `.env` inside the same directory.

Now let's give the following fields a value - I will explain what each field means:

| Key | Example value | Meaning |
|----------|----------|----------|
| HOSTNAME    | FMSMaster   | This will be the hostname of the docker image. FileMaker clients will see this name under each hosted application. Later we will use a reverse proxy on our machine to point to this docker image!   |
| NAME    | FMSMaster   | This will be the name of the docker image itself. The value can match the hostname - as shown in this example.  |
| HTTPS_PORT    | 443   | This is the HTTPS port that will be exposed on the OS. Make sure this port is free to use on your system. We will use our nginx reverse proxy (explained later) to route all /admin-console traffic to the FileMaker server.    |
| FM_PORT    | 5003   | This is the port currently used for connecting to any hosted database. This is a standard port and should not be changed unless you want to add the port number to each machine connecting to FileMaker. Note that in the future FileMaker will drop this port and make use of the HTTPS port AND PROTOCOL (thank god!)   |
| JAPI_PORT    | 4444   | This port will be used to send API requests too. Inside the docker image we have a Laravel API that will handle the JDBC connection. This allows use to use SQL queries to receive and store information from an external source.  |
| X_PORT    | 32342   | This port is port used for debugging the image. It is optional. Recommended to be commented out.  |
| FM_DATA_PATH    | ./data   | This path will be used by FileMaker to write the databases and the backups. This path is really important. If the docker image is rebuild - the data is kept safe on your machine - meaning the data is persistent.  |
| FM_LICENSE_PATH    | ./license   | This path will be used by FileMaker to import the license on installing. This path is optional. The license should be inside the folder with name `license.cert` if you wish to auto-import it during installation. If you didn't expose this path or added the license.cert - you can always manually add the license in the web GUI later on.  |
| FM_SCHEDULE_PATH    | ./schedules   | This path will be used by FileMaker to import the backup and/or script schedules. This path is optional. A schedule file should be inside the corresponding subfolder eg `/schedules/backups/fms_settings.settings` and/or `/schedules/scripts/fms_settings.settings` if you wish to auto-import it during installation. If you didn't expose this path or added the fms_settings.settings - you can always manually add the schedules in the web GUI later on.|
| FM_CERTIFICATE_PATH    | ./certificates   | This path will hold the certificates used to connect over a secure connection over the `FM_PORT` (default:5003). Note this path is also used when updating the certificates once they are expired. The following files need to be present in order to copy them to the docker: `cert.pem`, `privkey.pem` and `fullchain.pem`.|
| FM_USERNAME    | admin   | The username for the server. This is the username you will use to login to the /admin-console.|
| FM_PASSWORD    | MySecurePassword   | The password for the server. This is the password you will use to login to the /admin-console.|
| FM_PIN    | 1234   | The pincode for the server. This is the pincode you will use to recover the admin account in case you lost the login credentials.|
| JDBC_USERNAME    | api   | This is the username for a database you want to connect to. |
| JDBC_PASSWORD    | myApiPassword   | This is the password for a database you want to connect to. |
| JDBC_DATABASE    | database.fmp12   | This is the database you want to connect to. |
| JDBC_TEST_QUERY    | SELECT * FROM Contacts   | This is the test query for JDBC connection test. |

### B. (optional) Importing of backup/script schedules

Create the following directories and copy over a valid fms_settings.settings file to each directory.

My downloaded backup schedules from another FileMaker server installation:

`fms_settings.settings` -> `./schedules/backups/fms_settings.settings`

**AND/OR**

My downloaded script schedules from another FileMaker server installation:

`fms_settings.settings` -> `./schedules/scripts/fms_settings.settings`

*Note: This action can be initiated inside the GUI after the installation. No schedule file will be inserted **AFTER** the first installation of this software - the only way to insert a schedule will be manually trough the GUI (recommended) **OR** by rebuilding the image (not recommended)!*

### C. (optional) Importing license

Create the following directory and copy over a valid license.fmcert file.

My downloaded license file from Claris:

`license.fmcert` -> `./license/license.fmcert`

*Note: This action can be initiated inside the GUI after the installation. No license file will be inserted **AFTER** the first installation of this software - the only way to insert the license will be manually trough the GUI (recommended) **OR** by rebuilding the image (not recommended)!*

### D. (optional) Importing certificates

Create the following directory and copy over the certificate files, cert.pem, privkey.pem and fullchain.pem.

My certificates obtained from a certificate provider:

`cert.pem` -> `./certificates/cert.pem`,

`privkey.pem` -> `./certificates/privkey.pem`,

`fullchain.pem` -> `./certificates/fullchain.pem`

*Note: Unlike the previous steps - this step can be repeated by calling a script inside the running image. More information will follow.*

### E. Downloading and selecting a FileMaker Server version

To download a FileMaker server version you have 4 options. The first 3 options are `old`, `stable`and `new`. The last option is `specific` where you specify the version to download by giving an URL.

I recommend using the `stable` version for every deployment.

If you would chose to specify your own version you should do so by entering in the version **AND** download URL. Eg 20.3.2.205 https://downloads.claris.com/esd/fms_20.3.2.205_Ubuntu22_amd64.zip

Let's use the stable version:

Run `./manager.sh` and select option `Download FileMaker Server installation media` enter `stable`.
After its done downloading, select option `Set FileMaker Server version` enter `stable`.

After downloading and setting the needed files we can start to create our image.

## 2. Building the image

After doing the setup we are ready for our first build! Let's build the image by running:

Run `./manager.sh` and select option "Build Docker image"

This might take some time depending on the system. The docker image will start automatically

## 3. Inserting our own first FileMaker application

Let's add our own FileMaker application now that everything is installed. Copy over your database.fmp12 file into the following directory:

`./data/Databases/database.fmp12`

*Note: replace database.fmp12 with the database you wish to add.*

After adding the database surf to the local machine on the https port - followed by /admin-console. Eg https://localhost/admin-console

After doing so login using the credentials u provided inside the .env file and open the database. You should now be able to add the host `localhost` in FileMaker and connect to the application.

Now before continuing we need to make sure the API-user has ODBC/JDBC access. Go to `File -> Manage -> Security` and edit the access-rights for your API-user. Enable ODBC/JDBC access.

*Note: I included a database.fmp12 file inside test-database folder, that can be used for testing purposes. The login credentials are Admin/admin. We can use this file to test the JDBC connection too.*

## 4. Installing SSL certificates

*Note: I won't explain how to receive SSL certificates - only how to import them. Requesting certificates on our server is done using certbot.*

**To install the certificates it is MANDATORY to close all active databases. Please check if anyone is using any hosted database before closing it.**

**First make sure the certificates can be found in the certificate folder defined inside the .env file. If the files are not present these steps won't work.**

Run `./manager.sh` and select option `Stop all FileMaker databases`
Next select option `Import SSL certificates`
Next select option `Stop Docker container`
Next select option `Start Docker container`

Verify if the SSL certificates are installed correctly!

## 5. Changing FileMaker version

*Note: Make sure you have a backup of the databases, schedules (backup and script).*

**To change FileMaker server version it is MANDATORY to close all active databases. Please check if anyone is using any hosted database before closing it. Removing the original docker image will also be needed! Make sure to test any new versions with this docker ON A TESTING SERVER FIRST!**

Run `./manager.sh` and select option `Stop all FileMaker databases`
Next select option `Stop Docker container`
Next select option `Remove Docker container`
Next follow the actions described inside `Downloading and selecting a FileMaker Server version`
Next follow the actions described inside `Building the image`

## 6. More options

Inside `./manager.sh` more actions are available. If I have time I will write the instructions too!
