# Hướng dẫn cài đặt Frappe HR

Các thành phần cần cài đặt:
* MariaDB v10.11
* Redis v7 (Cache, Queue, và SockerIO)
* Frappe HR

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
  -p 6379:6379 \
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
  -p 6379:6379 \
  docker.io/library/redis:7 \
  --maxmemory 128mb \
  --maxmemory-policy allkeys-lru
```

## Cài đặt Frappe HR

Build image

```bash
podman build \
 --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
 --build-arg=FRAPPE_BRANCH=version-15 \
 --build-arg=APPS_JSON_BASE64=WwogIHsKICAgICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL2ZyYXBwZS9ocm1zIiwKICAgICJicmFuY2giOiAidmVyc2lvbi0xNSIKICB9Cl0= \
 --tag=frappe-hr:15 .
```

Giá trị của tham số `APPS_JSON_BASE64` trong lệnh build trên là base64 từ chuỗi JSON sau:

```json
[
  {
    "url": "https://github.com/frappe/hrms",
    "branch": "version-15"
  }
]
```

Thiết lập ứng dụng trước khi cài

```bash
podman volumne create frappe-sites
```

```bash
podman run --rm -it \
  --network frappe \
  -e MARIADB_HOST=mariadb \
  -e MARIADB_PORT=3306 \
  -e REDIS_CACHE=redis-cache:6379 \
  -e REDIS_QUEUE=redis-queue:6379 \
  -e REDIS_SOCKETIO=redis-socketio:6379 \
  -p 8000:8000 \
  -p 9000:9000 \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe-hr:15 \
  /home/frappe/frappe-bench/init-hrms.sh
```

Cài đặt Web

```bash
podman run -d \
  --network frappe \
  --name frappe-web \
  -e SITE_NAME=hr.digigov.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe-hr:15
```

Cài đặt Worker

```bash
podman run -d \
  --network frappe \
  --name frappe-worker \
  -e SITE_NAME=hr.digigov.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe-hr:15 \
  bench worker
```

Cài đặt Scheduler

```bash
podman run -d \
  --network frappe \
  --name frappe-scheduler \
  -e SITE_NAME=hr.digigov.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe-hr:15 \
  bench schedule
```

Cài đặt Websocket

```bash
podman run -d \
  --network frappe \
  --name frappe-websocket \
  -e SITE_NAME=hr.digigov.vn \
  -v frappe-sites:/home/frappe/frappe-bench/sites \
  frappe-hr:15 \
  node /home/frappe/frappe-bench/apps/frappe/socketio.js
```


## Tham khảo

Frappe HR Docker Compose: https://github.com/frappe/hrms/tree/develop/docker

Frappe Docker: https://github.com/frappe/frappe_docker

Frappe Framework Configuration: https://docs.frappe.io/framework/v15/user/en/basics/site_config
