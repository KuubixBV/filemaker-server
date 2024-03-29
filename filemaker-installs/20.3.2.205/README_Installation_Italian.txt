[ Istruzioni per l'installazione di FileMaker Server ]

1. Eseguire il comando seguente per installare FileMaker Server in modo interattivo, dove $PACKAGE_PATH indica il percorso del pacchetto di installazione.
   $ sudo apt install $PACKAGE_PATH/filemaker-server-VN.BN-AR.deb

2. Aprire il file "Claris FileMaker Server Admin Console.html" sul desktop e accedere all'Admin Console di FileMake Server.

Note:

- Il passo 2 è necessario solo se si installa FileMaker Server su Ubuntu Desktop. Per FileMaker Server su Ubuntu Server è possibile accedere alla Admin Console da un computer remoto utilizzando l'URL https://[host]/admin-console.
- VN, BN e AR indicano la versione di rilascio, il numero di build e l'architettura.
Per informazioni dettagliate, consultare queste guide: 
   Guida all'installazione e alla configurazione di Claris Server e FileMaker Server (https://www.filemaker.com/redirects//fms20_admin.html?page=doc_getting_started&lang=it) 
   Guida all'installazione e alla configurazione di rete di Claris Server e FileMaker Server (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_nisg&lang=it)