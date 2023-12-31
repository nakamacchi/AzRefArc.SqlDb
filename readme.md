
# テスト用 pubs データベースの作成方法について

## pubs データベースとは

SQL Server 2000 に添付されていたサンプルデータベースで、出版社のデータを模倣した、シンプルな構造を持つデータベースです。Northwind データベースや Adventure データベースなどと同様、簡単なテスト用のデータベースとして利用されていました。現在は GitHub 上にて[インストールスクリプト](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instpubs.sql)が MIT ライセンスにて公開されています。

![picture 3](images/5574b19713ad932af5b6338e23e80becc0d132695ccd031ae39be4d28ac6d184.png)  

これらのデータベースは非常にシンプルなため、現在でも便利に利用できます。セットアップにはこのスクリプトの一部を書き換えたインストールスクリプト（[pubs_azure_with_timestamp.sql](pubs_azure_with_timestamp.sql)）を利用します。主な書き換えポイントは以下の 2 つです。

- DB 作成処理を除去（Azure SQL DB に対応できるようにするため）
- authors テーブルにタイムスタンプ列を追加（楽観同時実行制御を用いたデータ更新の例を示すため）

## データベース管理ツールの選択肢

データベースの作成やデータ編集には、何らかのデータベース管理ツールが必要です。SQL Server データベースに直接アクセスしてスキーマやデータを確認するためのツールとしては以下があります。いずれを利用しても構いませんが、以前から SQL Server をお使いの方であれば SSMS を、新規に利用される方であれば Azure Data Studio をご利用いただくとよいと思います。

- SSMS (SQL Server Management Studio)
- ADS (Azure Data Studio)
- VS Data Explorer (Visual Studio)

1. SSMS (SQL Server Management Studio)\
昔からある SQL Server の管理ツールです。SQL Server のフルセットの管理機能が提供されますが、Windows マシンでのみ利用可能です。[ここ](https://learn.microsoft.com/ja-jp/sql/ssms/download-sql-server-management-studio-ssms)からダウンロードできます。\
![picture 4](images/d5040dece73c5aee320964b36420e854a8607d2e75762f6b0d997a7677d990b9.png)  

2. ADS (Azure Data Studio)\
Windows, Linux, macOS などのマルチ OS に対応した新しい管理ツールです。近代的な開発に対応しており、ソースコードコントロール対応、Jupiter Notebook 統合などがサポートされています。[ここ](https://learn.microsoft.com/ja-jp/sql/azure-data-studio/download-azure-data-studio)からダウンロードできます。\
![picture 5](images/6e32d7b83d35113a8e0355e5f7eca8948c276ae069fc91d5a98966908d5dbeab.png)  

3. VS Data Explorer (Visual Studio)\
Visual Studio にはデータエクスプローラと呼ばれる機能が含まれており、これを用いて SQL Server の簡易な管理ができます。中身は SSMS から開発に必要となる基本的なデータ操作機能を切り出したもの、と考えるとよいでしょう。Visual Studio を利用している場合にはこのツールで済ませてしまってもよいと思います。\
![picture 6](images/67bb55b225a813b5632b153123b7d9272883c05179a0e914b44096218134572b.png)  

## テスト用のデータベースサーバ作成の選択肢

また、開発用のデータベースサーバを立てる必要がありますが、手軽に SQL Server を立てる主な方法としては以下のようなものがあります。（他にも SQL Server Express Edition などいくつかの選択肢がありますが、ここでは以下の 4 つをご紹介することにします。）

1. ローカルマシンに SQL Server を立てる\
開発者向け SQL Server である Developer Edition をローカルマシンにインストールして利用する方法です。以前から SQL Server を使われている方には最も馴染みのある方法だと思います。\
![picture 7](images/b42d457d26e9272b2ea4554adf5303d83c06aea179044aa1319bae25b4dbefc5.png)  

2. SQL Server の Docker イメージを利用する\
Linux 版 SQL Server はインストール済み Docker イメージが配布されています。これを利用すると簡単に SQL Server が立てられます。\
![picture 8](images/1a9b19c465ba857ebb39bde5435c09fe4f33cb8f1467e31c79e268b59cc72c75.png)  

3. カスタム Docker イメージを作成・利用する\
前述の方法も便利ですが、この方法だと、コンテナを削除して作り直すと、また改めて SQL Server のクリーンインストールイメージにサンプル DB をセットアップし直す必要が生じます。このため Dockerfile を利用して、このセットアップ処理を自動化してしまう、という方法もあります。\
![picture 9](images/1e4871b7b2b4bf0105548df24df75b134fd7882650272c6fe5d908a65cc826ad.png)  

4. Azure SQL Database を利用する\
最後に、Azure サブスクリプションを持っている場合には、そこに SQL データベースを立てておくと便利です。最も小さいサイズで作成しておけば、課金も少なくて済みます。筆者は複数のサンプルアプリから同一の DB を利用するため、主にこの方法を使っています。\
![picture 10](images/838a4c04b3eef6f4c7fca2d493857dedd6d6d79e43984ebbb89edcd18fb0bce0.png)  


以降では、各方法でデータベースをセットアップする方法を解説します。

## 1. ローカルマシンに SQL Server を立てる

![picture 8](images/b42d457d26e9272b2ea4554adf5303d83c06aea179044aa1319bae25b4dbefc5.png)  

SQL Server には、開発・テスト用途として無償で利用できる、開発者エディション（Developer Edition）と呼ばれるものがあります。これをローカルマシンにインストールして利用することができます。以下に具体的な方法を示します。

### セットアップ方法

- [ここ](https://www.microsoft.com/ja-jp/sql-server/sql-server-downloads)から SQL Server Developer Edition のインストーラを入手します。
- インストーラ起動後、「メディアのダウンロード」を選択すると、ISO メディアをダウンロードできます。\
![picture 11](images/d5782e4cbb225a679501ec423421f50469abc4071e8d7a1ded1f154731206ea8.png)  
- ダウンロードした ISO をマウントし、管理者コマンドラインから以下のコマンドでセットアップしてください。（パスワード SAPWD は複雑なものが必要なため、適宜変更してください。またローカル管理者アカウント SQLSYSADMINACCOUNTS の名前は Administrator 以外の場合もありますのでこちらも適宜変更してください。）
```
setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install" /FEATURES=SQL,Tools /INSTANCENAME=MSSQLSERVER /SECURITYMODE=SQL /SAPWD=“XXXXXXXX" /SQLSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE" /SQLSVCSTARTUPTYPE="Automatic" /SQLSYSADMINACCOUNTS=".\Administrator"
```

### データ準備方法

- ローカルマシンにインストールした SQL Server に対して、SSMS や ADS などのツールから接続します。主な設定項目は以下の通りです。
  - サーバ名 : localhost
  - ユーザ名 : sa
  - パスワード : セットアップ時の指定値
  - サーバ証明書を信頼する (Trust Server Certificate) : はい\
  ※ localhost でアクセスを行う＝サーバ名を使っていないため、そのままでは通信暗号化に利用するサーバの証明書が信頼できません。このため、この設定を True にしています。
- 接続後、サーバを右クリックし、新規 DB を作成します。
  - データベース名 : pubs
- 作成した DB "pubs" を選択し、「新しいクエリ」を選択します。
- 接続先 DB が ("master" ではなく) "pubs" になっていることを確認した上で、インストールスクリプト（"[pubs_azure_with_timestamp.sql](pubs_azure_with_timestamp.sql)"）の中身を貼り付けて実行してください。\
![picture 12](images/db9c3a0922e17b563a008e0545eeb6fc3121d279ee2aa6f54fb4d32c9db2479f.png)  

### アプリからの接続

- 以下の接続文字列を書き換えて利用してください。
  - 主な書き換え場所はパスワードです。
  - TrustServerCertificate が True に設定されていることを確認してください。

``` web.config の設定例
<add name="PubsConnection" providerName="System.Data.SqlClient" connectionString="Server=localhost;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;ConnectRetryCount=3;ConnectRetryInterval=30;Connection Timeout=60;Language=Japanese;" />
```

``` ユーザシークレットの設定例
{
  "ConnectionStrings": {
    "PubsDbContext": "Server=localhost;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}
```

なお、SQL Server のメディアからの既定のインストールでは名前付きパイプ接続のみが有効ですが、この名前付きパイプ接続はローカルマシン内での通信にしか利用できません。このため、この SQL Server に対してリモートマシンから接続したい場合には、追加で以下 2 つの作業を行ってください。

- SQL Server サービスマネージャから TCP 接続を有効化\
（※ 設定変更後、SQL Server サービスの再起動が必要）
- 当該マシンのファイアウォール設定を変更し、1433 ポートへの着信を許可

## 2. SQL Server の Docker イメージを利用する

![picture 9](images/1a9b19c465ba857ebb39bde5435c09fe4f33cb8f1467e31c79e268b59cc72c75.png)  

Linux 版 SQL Server に関しては、クリーンインストール済みの Docker イメージが配布されています。これを利用すると簡単に SQL Server が立てられます。

### セットアップ方法

- Docker Desktop などを利用し、自マシン内に Docker をインストールします。(WSL2 をインストールしてその中に Docker を立てる方法でも構いません。)
- SQL Server のイメージを pull して実行します。実行の際、いくつかの環境変数を設定します。
  - MSSQL_PID=Developer　これにより Developer Edition 相当として利用することができます。
  - MSSQL_SA_PASSWORD=XXXXXXXX　ここには適切・複雑なパスワードを設定してください。

```
sudo docker pull mcr.microsoft.com/mssql/server:2022-latest

sudo docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=XXXXXXXX" -e "MSSQL_PID=Developer" -e "MSSQL_TCP_PORT=1433" -p 1433:1433 --name sqlcontainer --hostname sqlserver -d mcr.microsoft.com/mssql/server:2022-latest
```

- 起動後、docker ps -la でコンテナが正しく起動していることを確認してください。

```
$ docker ps -la
CONTAINER ID   IMAGE                                        COMMAND                  CREATED         STATUS         PORTS                                       NAMES
0bb86ab1ef97   mcr.microsoft.com/mssql/server:2022-latest   "/opt/mssql/bin/perm…"   4 seconds ago   Up 3 seconds   0.0.0.0:1433->1433/tcp, :::1433->1433/tcp   sqlcontainer
```

### データ準備方法

- ローカルマシンの Docker に立てた SQL Server は、TCP 1433 ポートで動作しています。ここに対してツールから接続します。
  - サーバ名 : tcp:127.0.0.1,1433
  - ユーザ名 : sa
  - パスワード : セットアップ時の指定値
  - Trust server certificate (サーバ証明書を信頼する) : True\
  ※ localhost でアクセスを行う＝サーバ名を使っていないため、そのままでは通信暗号化に利用するサーバの証明書が信頼できません。このため、この設定を True にしています。
![picture 13](images/671a94d72d37333aa2883e35f50487d0cb1cf90650abfae4759ee8882e2c5e5f.png)  
- サーバに対して New Query を選択して以下を実行します。
```
create database pubs
```
- データベースを "master" から "pubs" に切り替えます。
- 接続先 DB が "pubs" になっていることを確認した上で、インストールスクリプト（"[pubs_azure_with_timestamp.sql](pubs_azure_with_timestamp.sql)"）の中身を貼り付けて実行します。
![picture 14](images/fe341d056c1c4a28f5590b5ad04f2304f0e9c4339b786377c7dcb5adf8dd8b9f.png)  

### アプリからの接続

- 以下の接続文字列を書き換えて利用してください。
  - 主な書き換え場所はパスワードです。
  - 接続先はローカルマシンの TCP 1433 ポートになります。localhost または 127.0.0.1 でアクセスするため、SQL Server のサーバ証明書が信頼できません。このため、TrustServerCertificate を True に設定して接続します。

``` web.config の設定例
<add name="PubsConnection" providerName="System.Data.SqlClient" connectionString="Server=tcp:127.0.0.1,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;ConnectRetryCount=3;ConnectRetryInterval=30;Connection Timeout=60;Language=Japanese;" />
```

``` ユーザシークレットの設定例
{
  "ConnectionStrings": {
    "PubsDbContext": "Server=tcp:127.0.0.1,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}
```

## 3. カスタム Docker イメージを作成・利用する

前述の方法はクリーンインストールされた SQL Server を素早く立てられるという意味で便利ですが、一方、コンテナで立てた場合には（仮想マシンとして立てた場合と異なり削除・作り直しが便利なことから）、比較的頻繁にコンテナを作り直したい、というケースが多いと思います。しかし前述の方法で用意したコンテナを立て直すと、クリーンインストールの状態に戻ってしまう、すなわちサンプル DB を再セットアップする必要が生じます（当たり前ですが）。

また、開発チーム内の各開発者の PC ごとにデータベースを立てるような場合も、各開発者にいちいちデータベースをセットアップさせるのはさすがに面倒です。

このような場合、Dockerfile を利用して、このセットアップ処理を自動化してしまうと便利です。以降にその方法を解説します。

### セットアップとデータ準備の方法

- 以下の Dockerfile を作成します。
  - SQL Server のパスワード（SA_PASSWORD）は複雑なパスワードに変更してください。
- 実施している作業は以下の通りです。
  - SQL Server に対して与える環境変数を設定しておきます。
  - 以下の一連の作業を行うシェルスクリプト sql-server-startup.sh を作成します。
    - SQL Server を起動する。
    - sqlcmd コマンドを利用して、SQL Server が起動するまで待機する。
    - create database でデータベースを作成する。
    - 作成したデータベースに接続し、インストールスクリプト（"[pubs_azure_with_timestamp.sql](pubs_azure_with_timestamp.sql)"）の中身を実行する。
    - （データベースが終了しないように）ログをコンソールに出力し続ける。
  - CMD 命令により、コンテナ起動時に上記のシェルスクリプトが実行されるように仕込んでおきます。

``` Dockerfile
FROM mcr.microsoft.com/mssql/server:2022-latest
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD="XXXXXXXX"
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433

# 必要なファイルをコピー
COPY ./pubs_azure_with_timestamp.sql /tmp/

# SQL Server起動スクリプトの作成
RUN echo '#!/bin/bash\n\
/opt/mssql/bin/sqlservr --accept-eula &' > /tmp/sql-server-startup.sh && \
echo 'until /opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -q"select 1" ; do sleep 5; done' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -q"create database pubs;"' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -d"pubs" -i"/tmp/pubs_azure_with_timestamp.sql"' >> /tmp/sql-server-startup.sh && \
echo 'tail -f /dev/null' >> /tmp/sql-server-startup.sh

# 実行権限の付与
RUN chmod +x /tmp/sql-server-startup.sh

# スクリプトの実行
CMD /tmp/sql-server-startup.sh
```

- Dockerfile をセットアップスクリプト（[pubs_azure_with_timestamp.sql]()）と同じフォルダに置いてビルドを行います。

```
# コンテナ作成
docker build . -t pubs
```

- docker run コマンドでコンテナを起動します。

```
# コンテナ起動
docker run -p 1433:1433 --name pubs pubs:latest
```

![picture 15](images/cc35463262ded9e7ef92eda027995ef544982aeca673a47344b836455ed776b5.png)  

- コンテナはフォアグラウンドで動作するようにしてあります。このため、コンテナを停止したい場合には、別のコマンドプロンプトを開き、以下のコマンドを実行します。

```
# コンテナ削除（別ウィンドウから）
docker kill pubs
docker rm pubs
```

### アプリからの接続

- 以下の接続文字列を書き換えて利用してください。（前節の「2. SQL Server の Docker イメージを利用する」と同じです。）
  - 主な書き換え場所はパスワードです。
  - 接続先はローカルマシンの TCP 1433 ポートになります。localhost または 127.0.0.1 でアクセスするため、SQL Server のサーバ証明書が信頼できません。このため、TrustServerCertificate を True に設定して接続します。

``` web.config の設定例
<add name="PubsConnection" providerName="System.Data.SqlClient" connectionString="Server=tcp:127.0.0.1,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;ConnectRetryCount=3;ConnectRetryInterval=30;Connection Timeout=60;Language=Japanese;" />
```

``` ユーザシークレットの設定例
{
  "ConnectionStrings": {
    "PubsDbContext": "Server=tcp:127.0.0.1,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=sa;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  }
}
```

## 4. Azure SQL Database を利用する

1～3 の方法はローカルマシンにテスト用データベースサーバを立てる方法ですが、筆者のように様々なサンプルアプリを作成している場合には、そのつどテスト用のサーバを準備するのは面倒です。

Azure サブスクリプションを持っている場合には、そこに SQL データベースを立てっぱなしにしておくと便利です。最も小さいサイズで作成しておけば、課金も少なくて済みます。\
![picture 10](images/838a4c04b3eef6f4c7fca2d493857dedd6d6d79e43984ebbb89edcd18fb0bce0.png)  

### セットアップ方法

- Azure ポータルから、SQL Server （論理サーバ）を作成します。
  - 名前やリソースグループは適宜調整してください。
  - 認証方式は、本番環境などでは Azure AD 認証を利用した方がよいですが、開発やテストの目的であれば SQL 認証を利用するのが手軽です。
![picture 16](images/62dc060b99ebab02cfd74de1e86f102452698e44bb26e6d8d9921a186a176842.png)  
- 作成した SQL Server（論理サーバ）上に、pubs データベースを作成します。
- DB 作成時に、以下のいずれかの SKU を選択するとコストを抑えることができます。
  - General Purpose + Serverless（ディスクサイズを 1GB まで減らすとさらに安価にできる）
  - Basic （5 DTU, 2 GB）
![picture 17](images/d7c1d122cc34b690d65171ea4af3643166b729ab1f831992c5eaccba1a3016b8.png)  
- 論理サーバ、DB それぞれに対して、現在のクライアント IP アドレスからのアクセスを許可しておきます。

## データ準備方法

- クラウド上の SQL データベースに対して管理ツールから接続します。
  - サーバ名 : XXXX.database.windows.net （論理サーバ名を利用）
  - ユーザ名 : セットアップ時の指定値
  - パスワード : セットアップ時の指定値
  - 接続先データベース名 : pubs\
    ※ 正しいサーバ名（FQDN）でアクセスしますので、サーバ証明書の強制信頼の設定は不要です。
![picture 18](images/1c8f05503a54c997ccbb5921b90751ac38975fe85d92e395e0eff97487fbc18b.png)  

- 作成した DB を選択し、「新しいクエリ」を選択します。
- 接続先 DB が "pubs" になっていることを確認した上で、インストールスクリプト（"[pubs_azure_with_timestamp.sql](pubs_azure_with_timestamp.sql)"）の中身を貼り付けて実行してください。
![picture 19](images/84778fc5df894eb89ea5fbb488c8996c1d7fbd0fca67a46ceab23275e1b87e81.png)  

### アプリからの接続

- 以下の接続文字列を書き換えて利用してください。
  - 主な書き換え場所はサーバ名、ユーザ名、パスワードです。
  - 正しい FQDN 名でアクセスするため、TrustServerCertificate は False のままで大丈夫です。

``` web.config の設定例
<add name="PubsConnection" providerName="System.Data.SqlClient" connectionString="Server=tcp:XXXX.database.windows.net,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=XXXXXXXX;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;ConnectRetryCount=3;ConnectRetryInterval=30;Connection Timeout=60;Language=Japanese;" />
```

``` ユーザシークレットの設定例
{
  "ConnectionStrings": {
    "PubsDbContext": "Server=tcp:XXXX.database.windows.net,1433;Initial Catalog=pubs;Persist Security Info=False;User ID=XXXXXXXX;Password=XXXXXXXX;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
```

# Pubs データベースの中身について

pubs データベースは非常に古いデータベースのため、テーブル名やフィールド名の命名にも不適切な部分が数多く存在します。例えば下記はデータベース内の書籍テーブル（titles テーブル）ですが、一貫性のない命名規約が多く、このまま扱うとアプリケーションの可読性が落ちます。

![picture 20](images/911a50aca85b8b8f220fb0c5c974ebdeeb4c4ed86e5052652773de172ec3a1eb.png)  

これらは Entity Framework によって吸収するのがおすすめです。[pubs.cs ファイル](pubs.cs)には、pubs データベースのテーブル定義を Entity Framework で扱えるように変換したものが含まれています。このファイルを Visual Studio で開き、プロジェクトに追加して利用してください。
