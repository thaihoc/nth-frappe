# Hướng dẫn cài đặt Frappe ERPNext và HRMS

Các thành phần cần cài đặt:
* MariaDB v10.11
* Redis v7 (Cache, Queue, và SockerIO)
* Frappe ERPNext & HRMS v15

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
  docker.io/library/redis:7 \
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
  docker.io/library/redis:7 \
  --maxmemory 512mb \
  --maxmemory-policy noeviction
```

Cài Redis Socket IO

```bash
podman run -d \
  --name redis-socketio \
  --network frappe \
  -p 6381:6379 \
  docker.io/library/redis:7 \
  --maxmemory 128mb \
  --maxmemory-policy allkeys-lru
```

## Cài đặt Frappe ERPNext & HRMS

### Build image

```bash
podman build \
 --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
 --build-arg=FRAPPE_BRANCH=version-15 \
 --build-arg=APPS_JSON_BASE64=WwogIHsKICAgICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL2ZyYXBwZS9lcnBuZXh0IiwKICAgICJicmFuY2giOiAidmVyc2lvbi0xNSIKICB9LAogIHsKICAgICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL2ZyYXBwZS9ocm1zIiwKICAgICJicmFuY2giOiAidmVyc2lvbi0xNSIKICB9Cl0= \
 --tag=frappe:15 .
```

Giá trị của tham số `APPS_JSON_BASE64` trong lệnh build trên là base64 từ chuỗi JSON sau:

```json
[
  {
    "url": "https://github.com/frappe/erpnext",
    "branch": "version-15"
  },
  {
    "url": "https://github.com/frappe/hrms",
    "branch": "version-15"
  }
]
```

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

## Tham khảo

Frappe HR Docker Compose: https://github.com/frappe/hrms/tree/develop/docker

Frappe Docker: https://github.com/frappe/frappe_docker

Frappe Framework Configuration: https://docs.frappe.io/framework/v15/user/en/basics/site_config

## Mẹo xử lý

Thiết lập lại site

```bash
podman exec -it mariadb mysql -uroot -p123 -e "DROP DATABASE _b533f5fdd65aaf8c;"

podman volume rm frappe-sites
```

Xử lý lỗi user host scope

```sql
SELECT User, Host FROM mysql.user WHERE User='_3d29114af46bf1a6';
DROP USER '_3d29114af46bf1a6'@'10.89.1.24';
CREATE USER '_3d29114af46bf1a6'@'%' IDENTIFIED BY 'NZIZnzx2P0DCevk6'
GRANT ALL PRIVILEGES ON _3d29114af46bf1a6.* TO '_3d29114af46bf1a6'@'%';GRANsql
```