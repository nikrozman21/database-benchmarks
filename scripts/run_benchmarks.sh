#!/bin/bash

# Function to run benchmarks
function run_benchmark() {
  local db_container=$1
  local suffix=$2

  # Wait for MariaDB to be ready
  until mysqladmin ping -h $db_container --silent; do
    echo "Waiting for $db_container..."
    sleep 3
  done

  # Prepare the database
  mysql -h $db_container -uroot -prootpwd -e "CREATE DATABASE IF NOT EXISTS test;"
  
  # Prepare the database tables for OLTP read-write
  sysbench /usr/share/sysbench/oltp_read_write.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --tables=1 \
    --table-size=1000000 \
    prepare

  # Test 1: Read-only benchmark
  sysbench /usr/share/sysbench/oltp_read_only.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --table-size=100000 \
    --tables=1 \
    --threads=8 \
    --time=60 \
    --report-interval=10 \
    run | tee /output/read-only-log-$suffix.txt

  # Test 2: Read-write benchmark
  sysbench /usr/share/sysbench/oltp_read_write.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --table-size=100000 \
    --tables=1 \
    --threads=8 \
    --time=60 \
    --report-interval=10 \
    run | tee /output/read-write-log-$suffix.txt

  # Test 3: Insert-only benchmark
  sysbench /usr/share/sysbench/oltp_insert.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --table-size=100000 \
    --tables=1 \
    --threads=8 \
    --time=60 \
    --report-interval=10 \
    run | tee /output/insert-only-log-$suffix.txt

  # Test 4: Point-select benchmark
  sysbench /usr/share/sysbench/oltp_point_select.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --table-size=100000 \
    --tables=1 \
    --threads=8 \
    --time=60 \
    --report-interval=10 \
    run | tee /output/point-select-log-$suffix.txt

  # Test 5: Read-write with a larger table size
  sysbench /usr/share/sysbench/oltp_read_write.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    --table-size=200000 \
    --tables=1 \
    --threads=8 \
    --time=60 \
    --report-interval=10 \
    run | tee /output/read-write-large-log-$suffix.txt

  # Cleanup the tables after tests
  sysbench /usr/share/sysbench/oltp_read_write.lua \
    --mysql-host=$db_container \
    --mysql-db=test \
    --mysql-user=root \
    --mysql-password=rootpwd \
    cleanup
}

# Run benchmarks for each MariaDB container
run_benchmark mariadb_2cpu_2gb "2cpu-2gb"
run_benchmark mariadb_4cpu_4gb "4cpu-4gb"
run_benchmark mariadb_8cpu_8gb "8cpu-8gb"

echo "All benchmarks completed and JSON results are stored in /output"
