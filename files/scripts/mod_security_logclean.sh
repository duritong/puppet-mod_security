#!/bin/bash

# this cronjob cleans up any modsec logs
# that might be in logs of vhosts
ls -d /var/www/vhosts/*/logs 2>/dev/null | while read logdir; do
  find $logdir -mindepth 1 -maxdepth 1 -type d -mtime +5 -print0 | xargs -0 rm -rf
done
