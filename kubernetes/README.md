# Hướng dẫn cài đặt Frappe (ERPNext + HRMS) trên K8s

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

# App stacks
kubectl apply \
    -f frappe-worker.yaml \
    -f frappe-scheduler.yaml \
    -f frappe-web.yaml \
    -f frappe-frontend.yaml
```
