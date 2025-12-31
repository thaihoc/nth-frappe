# Hướng dẫn cài đặt Frappe (ERPNext + HRMS) trên K8s

Build docker image: [Build docker image](build-image.md)

Lần lượt run các lệnh sau

```bash
# DB & Redis
kubectl apply \
    -f mariadb.yaml \
    -f redis-cache.yaml \
    -f redis-queue.yaml \
    -f redis-socketio.yaml
```

```bash
# Init scripts
kubectl apply -n applications -f kubernetes/frappe-init.yaml
```

```bash
# App stack
kubectl apply -n applications `
    -f kubernetes/frappe-worker.yaml `
    -f kubernetes/frappe-scheduler.yaml `
    -f kubernetes/frappe-web.yaml `
    -f kubernetes/frappe-websocket.yaml `
    -f kubernetes/frappe-nginx.yaml
```

Chạy bằng github raw URL

```bash
kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/mariadb.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-cache.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-queue.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-socketio.yaml
```

```bash
kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-init.yaml
```

```bash
kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-worker.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-scheduler.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-web.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-websocket.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-nginx.yaml
```