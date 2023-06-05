FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD="p&ssw0rdp&ssw0rd"
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433

# 必要なファイルをコピー
COPY ./pubs_azure_with_timestamp.txt /tmp/

# SQL Server起動スクリプトの作成
RUN echo '#!/bin/bash\n\
/opt/mssql/bin/sqlservr --accept-eula &' > /tmp/sql-server-startup.sh && \
echo 'until /opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -q"select 1" ; do sleep 5; done' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -q"create database pubs;"' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -d"pubs" -i"/tmp/pubs_azure_with_timestamp.txt"' >> /tmp/sql-server-startup.sh && \
echo 'tail -f /dev/null' >> /tmp/sql-server-startup.sh

# 実行権限の付与
RUN chmod +x /tmp/sql-server-startup.sh

# スクリプトの実行
CMD /tmp/sql-server-startup.sh

# コンテナ作成
# docker build . -t pubs
# コンテナ起動
# docker run -p 1433:1433 --name pubs pubs:latest
# コンテナ削除（別ウィンドウから）
# docker kill pubs && docker rm pubs

