#!/bin/bash

# this cronjob cleans up any modsec logs
# that might be in logs of vhosts
test `ls /var/www/vhosts/* 2>/dev/null | grep logs | wc -l` -gt 0 \
&& find /var/www/vhosts/*/logs/ -maxdepth 1 -type d -mtime +5 -exec rm -rf {} \;
