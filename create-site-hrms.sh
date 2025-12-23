#!bin/bash

cd /home/frappe/frappe-bench

bench get-app erpnext
bench get-app hrms

bench new-site ${SITE_NAME:-hrms.localhost} 

bench --site ${SITE_NAME:-hrms.localhost} install-app hrms

bench use ${SITE_NAME:-hrms.localhost}