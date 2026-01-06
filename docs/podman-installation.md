# Hướng dẫn cài đặt Frappe (ERPNext + HRMS) trên Podman

Build docker image: [Build docker image](build-image.md)

Tạo network nếu chưa có:

```bash
podman network create frappe
```

## Cài đặt MariaDB

Tạo Volumn trên podman để lưu dữ liệu

```bash
podman volume create mariadb-data
```

Chạy MariaDB

```bash
podman run \
  --detach \
  --network frappe \
  --name mariadb \
  --env MARIADB_USER=frappe_hrms \
  --env MARIADB_PASSWORD=123 \
  --env MARIADB_ROOT_PASSWORD=123 \
  -p 3306:3306 \
  mariadb:10.11 \
  --bind-address=0.0.0.0 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci \
  --skip-character-set-client-handshake \
  --skip-innodb-read-only-compressed
```

## Cài đặt Redis

Cài đặt Redis Cache

```bash
podman run -d \
  --name redis-cache \
  --network frappe \
  -p 6379:6379 \
  docker.io/library/redis:7.2 \
  --maxmemory 256mb \
  --maxmemory-policy allkeys-lru
```

Cài đặt Redis Queue

```bash
podman volume create redis-queue-data
```

```bash
podman run -d \
  --name redis-queue \
  --network frappe \
  -p 6380:6379 \
  -v redis-queue-data:/data \
  docker.io/library/redis:7.2 \
  --maxmemory 512mb \
  --maxmemory-policy noeviction
```

Cài Redis Socket IO

```bash
podman run -d \
  --name redis-socketio \
  --network frappe \
  -p 6381:6379 \
  docker.io/library/redis:7.2 \
  --maxmemory 128mb \
  --maxmemory-policy allkeys-lru
```

## Cài đặt Frappe ERPNext & HRMS

### Thiết lập ứng dụng trước khi cài

Tạo volume lưu cấu hình và resources

```bash
podman volume create frappe-sites
```

Tạo cấu hình và resources (chỉ chạy một lần)

```bash
podman run --rm -it \
  --network frappe \
  -e DB_HOST=mariadb \
  -e DB_PORT=3306 \
  -e DB_ROOT_PASSWORD=123 \
  -e ADMIN_PASSWORD=121212 \
  -e REDIS_CACHE=redis-cache:6379 \
  -e REDIS_QUEUE=redis-queue:6379 \
  -e REDIS_SOCKETIO=redis-socketio:6379 \
  -e SITE_NAME=doanhnghiep.vn \
  -p 8000:8000 \
  -p 9000:9000 \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe:15 \
  /opt/frappe/init-scripts.sh
```

### Cài đặt các thành phần ứng dụng

Cài đặt Web

```bash
podman run -d \
  --network frappe \
  --name frappe-web \
  -e SITE_NAME=doanhnghiep.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  -p 8000:8000 \
  frappe:15
```

Cài đặt Worker

```bash
podman run -d \
  --network frappe \
  --name frappe-worker \
  -e SITE_NAME=doanhnghiep.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe:15 \
  bench worker
```

Cài đặt Scheduler

```bash
podman run -d \
  --network frappe \
  --name frappe-scheduler \
  -e SITE_NAME=doanhnghiep.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe:15 \
  bench schedule
```

Cài đặt Websocket

```bash
podman run -d \
  --network frappe \
  --name frappe-websocket \
  -e SITE_NAME=doanhnghiep.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  -p 9000:9000 \
  frappe:15 \
  node /home/frappe/frappe-bench/apps/frappe/socketio.js
```

Cài đặt Frontend

```bash
podman run -d \
  --network frappe \
  --name frappe-nginx \
  -e BACKEND=frappe-web:8000 \
  -e CLIENT_MAX_BODY_SIZE=50m \
  -e PROXY_READ_TIMEOUT=120 \
  -e SOCKETIO=frappe-websocket:9000 \
  -e UPSTREAM_REAL_IP_ADDRESS=127.0.0.1 \
  -e UPSTREAM_REAL_IP_HEADER=X-Forwarded-For \
  -e UPSTREAM_REAL_IP_RECURSIVE=off \
  -p 8080:8080 \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe:15 \
  nginx-entrypoint.sh
```

Như vậy là bạn đã cài đặt thành công. Truy cập vào đường dẫn `http://doanhnghiep.vn:8080` để sử dụng.

## Mẹo xử lý

Thiết lập lại site

```bash
podman exec -it mariadb mysql -uroot -p123 -e "DROP DATABASE _b533f5fdd65aaf8c;"

podman volume rm frappe-sites
```

Xử lý lỗi user host scope

```sql
SELECT User, Host FROM mysql.user WHERE User='_1f769b29284f5cab';
DROP USER '_1f769b29284f5cab'@'10.42.7.26';
CREATE USER '_1f769b29284f5cab'@'%' IDENTIFIED BY 'iXLyJbHC8BnOMxRX';
GRANT ALL PRIVILEGES ON _1f769b29284f5cab.* TO '_1f769b29284f5cab'@'%';
```