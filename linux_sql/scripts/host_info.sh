#!/bin/bash

# Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Collect hardware specs
lscpu_out=$(lscpu)
hostname=$(hostname -f)

cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk -F: '{print $2}' | xargs)
cpu_mhz=$(grep -m1 "cpu MHz" /proc/cpuinfo | awk -F: '{print $2}' | xargs)
l2_cache=$(cat /sys/devices/system/cpu/cpu0/cache/index2/size | sed 's/K//' | xargs)
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs)
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# Build INSERT statement
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem)
VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# Run it
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?
