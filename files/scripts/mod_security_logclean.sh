#!/bin/bash

# clean up mod_security log directories that are within
# a certain age
[ -z $1 ] && echo "USAGE: $0 days_to_keep" && exit 1
for vhost in /var/www/vhosts/*/logs; do
  if ls $vhost/20* 1> /dev/null 2>&1; then
    su - apache -s /bin/bash -c "tmpwatch -q ${1}d $vhost/20*"
    su - apache -s /bin/bash -c "find $vhost/20* -ignore_readdir_race -maxdepth 1 -mindepth 1 -type d -empty -delete"
    su - apache -s /bin/bash -c "find $vhost/20* -ignore_readdir_race -maxdepth 0 -mindepth 0 -type d -empty -delete"
  fi
done
su - apache -s /bin/bash -c "tmpwatch -q ${1}d /var/lib/mod_security"
