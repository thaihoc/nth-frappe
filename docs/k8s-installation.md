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

# Init scripts
kubectl apply -f frappe-init.yaml

# App stack
kubectl apply \
    -f frappe-worker.yaml \
    -f frappe-scheduler.yaml \
    -f frappe-web.yaml \
    -f frappe-websocket.yaml \
    -f frappe-frontend.yaml
```

Chạy bằng github raw URL

```bash
# DB & Redis
kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/mariadb.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-cache.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-queue.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/redis-socketio.yaml

kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-init.yaml

kubectl apply -n applications \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-worker.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-scheduler.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-web.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-websocket.yaml \
    -f https://raw.githubusercontent.com/thaihoc/nth-frappe/refs/heads/main/kubernetes/frappe-frontend.yaml
```
