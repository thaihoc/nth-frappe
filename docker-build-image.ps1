$APPS_JSON_BASE64 = [Convert]::ToBase64String(
  [Text.Encoding]::UTF8.GetBytes((Get-Content apps.json -Raw))
)

docker build `
 --build-arg FRAPPE_PATH=https://github.com/frappe/frappe `
 --build-arg FRAPPE_BRANCH=v16.0.0-rc.1 `
 --build-arg APPS_JSON_BASE64=$APPS_JSON_BASE64 `
 --tag frappe:16rc1-20260111 .