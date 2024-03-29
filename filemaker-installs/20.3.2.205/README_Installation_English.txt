[ Installation instructions for FileMaker Server ]

1. Run the following command to install FileMaker Server interactively, where $PACKAGE_PATH denotes the path of the installation package.
   $ sudo apt install $PACKAGE_PATH/filemaker-server-VN.BN-AR.deb

2. Open the 'Claris FileMaker Server Admin Console.html' file on your desktop and sign in to FileMaker Server Admin Console.

Notes:

- Step 2 is only required if you install FileMaker Server on Ubuntu Desktop. For FileMaker Server on Ubuntu Server, you can access Admin Console from a remote computer using the URL https://[host]/admin-console.
- VN, BN, and AR denote the release version, build number, and architecture.
For detailed information, see these guides:
   Claris Server and FileMaker Server Installation and Configuration Guide (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_getting_started&lang=en)
   Claris Server and FileMaker Server Network Install and Setup Guide (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_nisg&lang=en)