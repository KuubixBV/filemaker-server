[ Instructions d'installation pour FileMaker Server ]

1. Exécutez la commande suivante pour installer FileMaker Server de manière interactive, où $PACKAGE_PATH désigne le chemin du paquet d'installation.
   $ sudo apt install $PACKAGE_PATH/filemaker-server-VN.BN-AR.deb

2. Ouvrez le fichier « Claris FileMaker Server Admin Console.html » sur votre bureau et connectez-vous à l'Admin Console de FileMaker Server.

Remarques :

- L'étape 2 n'est requise que si vous installez FileMaker Server sur Ubuntu Desktop. Pour FileMaker Server sur Ubuntu Server, vous pouvez accéder à l'Admin Console à partir d'un ordinateur distant en utilisant l'URL https://[hôte]/admin-console.
- VN, BN et AR désignent respectivement le numéro de version, le numéro de build et l'architecture.
Pour des informations plus détaillées, consultez les guides suivants :
   Guide d'installation et de configuration de Claris Server et FileMaker Server (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_getting_started&lang=fr)
   Guide de configuration de l'installation réseau de Claris Server et FileMaker Server (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_nisg&lang=fr)