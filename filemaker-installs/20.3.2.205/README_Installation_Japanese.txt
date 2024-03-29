[ FileMaker Server のインストール手順 ]

1. FileMaker Server を対話型でインストールするには次のコマンドを実行します ($PACKAGE_PATH はインストールパッケージのパスを示します)。
   $ sudo apt install $PACKAGE_PATH/filemaker-server-VN.BN-AR.deb

2. デスクトップの「Claris FileMaker Server Admin Console.html」ファイルを開き、FileMaker Server Admin Console にサインインします。

メモ:

ステップ 2 は Ubuntu Desktop 上に FileMaker Server をインストールする場合にのみ必要です。Ubuntu Server 上の FileMaker Server の場合、URL https://[ホスト]/admin-console を使用してリモートコンピュータから Admin Console にアクセスできます。
- VN、BN、および AR はリリースバージョン、ビルド番号、およびアーキテクチャを示します。
詳細については、次のガイドを参照してください:
   Claris Server および FileMaker Server インストールおよび構成ガイド (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_getting_started&lang=ja)
   Claris Server および FileMaker Server ネットワークインストールセットアップガイド (https://www.filemaker.com/redirects/fms20_admin.html?page=doc_nisg&lang=ja)