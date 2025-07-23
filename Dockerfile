FROM mcr.microsoft.com/mssql/server:2022-latest
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD="p&ssw0rdp&ssw0rd"
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433

# 必要なファイルをコピー
COPY ./pubs_azure_with_timestamp.sql /tmp/

# sqlcmd コマンドを追加
USER root
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

# SQL Server起動スクリプトの作成
RUN echo '#!/bin/bash\n\
/opt/mssql/bin/sqlservr --accept-eula &' > /tmp/sql-server-startup.sh && \
echo 'until /opt/mssql-tools18/bin/sqlcmd -C -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -C -q"select 1" ; do sleep 5; done' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools18/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -C -q"create database pubs;"' >> /tmp/sql-server-startup.sh && \
echo '/opt/mssql-tools18/bin/sqlcmd -S127.0.0.1 -Usa -P"${SA_PASSWORD}" -C -d"pubs" -i"/tmp/pubs_azure_with_timestamp.sql"' >> /tmp/sql-server-startup.sh && \
echo 'tail -f /dev/null' >> /tmp/sql-server-startup.sh

# 実行権限の付与
RUN chmod +x /tmp/sql-server-startup.sh

# スクリプトの実行
CMD /tmp/sql-server-startup.sh
