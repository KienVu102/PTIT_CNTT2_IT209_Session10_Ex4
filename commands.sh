#!/bin/bash

# Bài 4: Thiết lập Custom Network & Named Volume bằng Docker CLI
# Script thực thi các thao tác Docker CLI

echo "=== Bước 1: Tạo Custom Bridge Network ==="
docker network create app-net

echo ""
echo "=== Bước 2: Tạo Named Volume ==="
docker volume create db-data

echo ""
echo "=== Bước 3: Khởi chạy Database Container ==="
docker run -d \
  --name db-server \
  --network app-net \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=testdb \
  postgres:15-alpine

echo ""
echo "=== Đợi Database khởi động (5 giây) ==="
sleep 5

echo ""
echo "=== Bước 4: Khởi chạy Backend Container ==="
docker run -d \
  --name app-container \
  --network app-net \
  -e DB_HOST=db-server \
  -e DB_PORT=5432 \
  -e DB_NAME=testdb \
  -e DB_PASSWORD=postgres \
  postgres:15-alpine \
  sleep 3600

echo ""
echo "=== Bước 5: Thêm dữ liệu test vào Database ==="
docker exec -it db-server psql -U postgres -d testdb -c "CREATE TABLE test_table (id SERIAL PRIMARY KEY, name VARCHAR(100));"
docker exec -it db-server psql -U postgres -d testdb -c "INSERT INTO test_table (name) VALUES ('Test Data 1'), ('Test Data 2');"
docker exec -it db-server psql -U postgres -d testdb -c "SELECT * FROM test_table;"

echo ""
echo "=== Bước 6: Kiểm tra DNS resolution từ Backend Container ==="
docker exec -it app-container ping -c 2 db-server

echo ""
echo "=== Bước 7: Xóa cứng Database Container ==="
docker rm -f db-server

echo ""
echo "=== Bước 8: Khởi chạy lại Database Container mới với cùng Volume ==="
docker run -d \
  --name db-server \
  --network app-net \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=testdb \
  postgres:15-alpine

echo ""
echo "=== Đợi Database khởi động (5 giây) ==="
sleep 5

echo ""
echo "=== Bước 9: Xác minh dữ liệu không bị mất ==="
docker exec -it db-server psql -U postgres -d testdb -c "SELECT * FROM test_table;"

echo ""
echo "=== Hoàn thành! ==="
echo "Kiểm tra Network: docker network ls | grep app-net"
echo "Kiểm tra Volume: docker volume ls | grep db-data"
echo "Kiểm tra Network details: docker network inspect app-net"
