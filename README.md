# Bài 4: Thiết lập Custom Network & Named Volume bằng Docker CLI

## Mục tiêu
Tạo Custom Bridge Network để các Container giao tiếp nội bộ qua tên service (DNS resolution) và tạo Named Volume lưu trữ dữ liệu bền vững.

## Yêu cầu
Kết nối cụm 2 Container (Backend Web API + PostgreSQL Database) bằng Docker CLI thủ công.

## Cấu trúc
- `commands.sh`: Script thực thi các thao tác Docker CLI
- `README.md`: Tài liệu hướng dẫn

## Các bước thực hiện

### 1. Tạo Custom Bridge Network
```bash
docker network create app-net
```

### 2. Tạo Named Volume
```bash
docker volume create db-data
```

### 3. Khởi chạy Database Container
```bash
docker run -d \
  --name db-server \
  --network app-net \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=testdb \
  postgres:15-alpine
```

### 4. Khởi chạy Backend Container
```bash
docker run -d \
  --name app-container \
  --network app-net \
  -e DB_HOST=db-server \
  postgres:15-alpine \
  sleep 3600
```

### 5. Test Data Persistence
1. Thêm dữ liệu vào Database
2. Xóa cứng container DB: `docker rm -f db-server`
3. Khởi chạy lại container DB mới gắn cùng Volume `db-data`
4. Xác minh dữ liệu không bị mất

## Lệnh kiểm tra

### Kiểm tra Network
```bash
docker network ls | grep app-net
docker network inspect app-net
```

### Kiểm tra Volume
```bash
docker volume ls | grep db-data
```

### Kiểm tra DNS Resolution
```bash
docker exec -it app-container ping -c 2 db-server
```

## Kết quả mong đợi
- Lệnh `ping db-server` từ Backend container giải mã thành công IP nội bộ của DB container
- Dữ liệu DB nguyên vẹn sau khi tái tạo container DB

## Cách chạy
```bash
chmod +x commands.sh
./commands.sh
```

## Dọn dẹp
```bash
docker rm -f db-server app-container
docker network rm app-net
docker volume rm db-data
```
