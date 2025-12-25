# Hướng dẫn build image cho Frappe ERPNext và HRMS v15

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