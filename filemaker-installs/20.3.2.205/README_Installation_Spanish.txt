[ Instrucciones de instalación para FileMaker Server ]

1. Ejecute el siguiente comando para instalar FileMaker Server de forma interactiva, donde $PACKAGE_PATH indica la ruta del paquete de instalación.
   $ sudo apt install $PACKAGE_PATH/filemaker-server-VN.BN-AR.deb

2. Abra el archivo "Claris FileMaker Server Admin Console.html" de su escritorio e inicie sesión en la Admin Console de FileMaker Server.

Notas:

- El paso 2 solo es necesario si instala FileMaker Server en Ubuntu Desktop. Para FileMaker Server en Ubuntu Server, puede acceder a la Admin Console desde un ordenador remoto a través de la URL https://[host]/admin-console.
- VN, BN y AR indican la versión de lanzamiento, el número de compilación y la arquitectura.
Para obtener información detallada, consulte estas guías:
   Guía de instalación y configuración de Claris Server y FileMaker Server (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_getting_started&lang=es)
   Guía de instalación y configuración en red de Claris Server y FileMaker Server (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_nisg&lang=es)