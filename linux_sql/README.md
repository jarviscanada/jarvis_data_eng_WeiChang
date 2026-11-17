# Introduction

The Linux Cluster Monitoring Agent is a tool designed to monitor Linux machines and keep track of their hardware and resource usage. It collects information such as CPU model, number of CPUs, total memory, CPU usage, free memory, disk I/O, and available disk space. This information is stored in a PostgreSQL database for later access and analysis. The project uses Bash scripts to collect the data, Docker to run PostgreSQL, and crontab to automate data collection at regular intervals. It can help users understand how their machines are performing and identify potential resource issues.



# Quick Start

## 1. Start the PostgreSQL Container

```bash
./scripts/psql_docker.sh create postgres password
./scripts/psql_docker.sh start
```

To check the container status or start it again:

```bash
docker ps -a
docker ps
docker start jrvs-psql
```

## 2. Create the Database and Tables

```bash
psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE host_agent;"
psql -h localhost -p 5432 -U postgres -f sql/ddl.sql
```

## 3. Collect Hardware Info

Run once to register the machine's hardware specifications:

```bash
bash scripts/host_info.sh localhost 5432 host_agent postgres password
```

## 4. Collect Hardware Usage Data

Run to collect the current resource usage:

```bash
bash scripts/host_usage.sh localhost 5432 host_agent postgres password
```

## 5. Automate Data Collection with Crontab

Open the crontab editor:

```bash
crontab -e
```

Add the following entry to collect usage data every minute:

```bash
* * * * * bash /home/<your-username>/<your-project-directory>/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log 2>&1
```

## 6. Validate Results

Connect to the database:

```bash
psql -h localhost -p 5432 -U postgres -d host_agent
```

Check the collected usage data:

```sql
SELECT * FROM host_usage;
```

# Implementation
## Architecture

The diagram below shows how monitoring agents running on Linux hosts collect system information and send it to a central PostgreSQL database.

<img width="855" height="596" alt="image" src="https://github.com/user-attachments/assets/a65aeec2-6d7c-4b5c-9e1f-08540c3a8281" />

## Scripts

### 1. psql_docker.sh
Creates, starts and stops the PostgreSQL Docker container. A Docker volume (`pgdata`) stores database data.

### 2. host_info.sh
Collects hardware information, including CPU details, hostname and total memory, and inserts it into `host_info`. Run once per host.

### 3. host_usage.sh
Collects resource usage, including free memory, CPU usage and disk statistics, and inserts it into `host_usage`.

### 4. Crontab
Automates `host_usage.sh` to run every minute, continuously recording resource usage.

### 5. queries.sql
Contains SQL queries used to analyse collected monitoring data and identify potential resource issues.


## Database Modeling

The project uses two PostgreSQL tables to store hardware information and resource usage.

### host_info

Stores hardware specifications for each monitored Linux machine.

| Column | Data Type | Description |
|---|---|---|
| id | SERIAL | Primary key |
| hostname | VARCHAR | Machine hostname (unique) |
| cpu_number | INT2 | Number of CPUs |
| cpu_architecture | VARCHAR | CPU architecture |
| cpu_model | VARCHAR | CPU model |
| cpu_mhz | FLOAT8 | CPU frequency in MHz |
| l2_cache | INT4 | L2 cache size |
| timestamp | TIMESTAMP | Record timestamp |
| total_mem | INT4 | Total memory in KB |

### host_usage

Stores resource usage measurements collected from each machine.

| Column | Data Type | Description |
|---|---|---|
| timestamp | TIMESTAMP | Measurement timestamp |
| host_id | SERIAL | Foreign key referencing `host_info.id` |
| memory_free | INT4 | Free memory in MB |
| cpu_idle | INT2 | CPU idle percentage |
| cpu_kernel | INT2 | CPU kernel usage percentage |
| disk_io | INT4 | Disk I/O |
| disk_available | INT4 | Available disk space in MB |

