#!/bin/bash

# clean up mod_security log directories that are within
# a certain age
[ -z $1 ] && echo "USAGE: $0 days_to_keep" && exit 1
ls -d /var/www/vhosts/*/logs 2>/dev/null | while read logdir; do
  find $logdir -mindepth 1 -maxdepth 1 -type d -mtime +${1} -print0 | xargs -0 rm -rf
done
