# 1. Create/start/stop the PostgreSQL container
./scripts/psql_docker.sh create postgres password
./scripts/psql_docker.sh start
./scripts/psql_docker.sh stop

# 2. Create the database and tables
psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE host_agent;"
psql -h localhost -p 5432 -U postgres -f sql/ddl.sql

# 3. Register this machine (run once)
bash scripts/host_info.sh localhost 5432 host_agent postgres password

# 4. Collect usage data (test once)
bash scripts/host_usage.sh localhost 5432 host_agent postgres password

# 5. Automate with cron (every minute)
crontab -e
* * * * * bash /home/rocky/dev/jarvis_data_eng_WeiChang/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log 2>&1
