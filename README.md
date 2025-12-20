# Hướng dẫn cài đặt Frappe HR

Các thành phần cần cài đặt:
* MariaDB v10.11
* Redis v7 (Cache, Queue, và SockerIO)
* Frappe HR


## Cài đặt MariaDB

Tạo Volumn trên podman để lưu dữ liệu:

```bash
podman volume create mariadb-data
```

Tạo network nếu chưa có:

```bash
podman network create frappe
```

Chạy MariaDB

```bash
podman run \
  --detach \
  --network frappe \
  --name mariadb \
  --env MARIADB_USER=nth \
  --env MARIADB_PASSWORD=123 \
  --env MARIADB_ROOT_PASSWORD=123 \
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
  -p 13000:6379 \
  docker.io/library/redis:7 \
  --maxmemory 256mb \
  --maxmemory-policy allkeys-lru
```

Cài đặt Redis Queue

```bash
podman volume create redis-queue-data

podman run -d \
  --name redis-queue \
  --network frappe \
  -p 11000:6379 \
  -v redis-queue-data:/data \
  docker.io/library/redis:7 \
  --maxmemory 512mb \
  --maxmemory-policy noeviction
```

Cài Redis Socket IO

```bash
podman run -d \
  --name redis-socketio \
  --network frappe-net \
  -p 12000:6379 \
  docker.io/library/redis:7 \
  --maxmemory 128mb \
  --maxmemory-policy allkeys-lru
```



## Tham khảo

Frappe HR Docker Compose: https://github.com/frappe/hrms/tree/develop/docker

Frappe Docker: https://github.com/frappe/frappe_docker
