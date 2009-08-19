#!/bin/bash
# this cronjob cleans up any modsec logs
# that might be in logs of vhosts
if [ `ls /var/www | grep vhosts | wc -l` -gt 0 ] && [ `ls /var/www/vhosts | wc -l` -gt 0 ] && [ `ls /srv/www/* | grep logs | wc -l` -gt 0 ]  && [ `ls /var/www/vhosts/*/logs/ | wc -l` -gt 0 ]; then
  find /var/www/vhosts/*/logs/ -maxdepth 1 -type d -mtime +5 -exec rm -rf {} \; 
fi
