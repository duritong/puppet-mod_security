#!/bin/sh

# Autoupdater for modsec rulesets.
#
# This script will attempt to update your rulefiles, and restart apache.
# If it apache does not start after changing rules, it will roll back to
# the old ruleset and restart apache again.
#
# Version: $Id: modsec.sh,v 2.0 2006/09/03 23:58:00 olei Exp $
# Based on a script by:
# URL: http://cs.evilnetwork.org/cycro
#
# Copyleft 2006, SkyHorse.Org, No Rights Reserved
# URL: http://www.skyhorse.org/web-server-administration/auto-update-modsecurity-rules-modsecsh/
#
# generic by skyhorse
# updated by Puzzle ITC
# improved by immerda.ch

APACHEINITD="/etc/init.d/httpd"
MODSECPATH="/etc/httpd/modsecurity.d/asl"

##########################################################################
######### you probably don't need to change anything below here ##########
##########################################################################

# internal
UPDATED=0
cd ${MODSECPATH}

listOfRules="20_asl_useragents.conf 60_asl_recons.conf domain-blacklist.txt malware-blacklist.txt 30_asl_antimalware.conf 98_asl_jitp.conf sql.txt 05_asl_exclude.conf 99_asl_exclude.conf domain-spam-whitelist.txt 05_asl_scanner.conf 99_asl_jitp.conf malware-blacklist-high.txt trusted-domains.txt 10_asl_antimalware.conf 40_asl_apache2-rules.conf Zour_excludes.conf malware-blacklist-local.txt whitelist.txt 10_asl_rules.conf 50_asl_rootkits.conf domain-blacklist-local.txt malware-blacklist-low.txt sql.txt"
baseUrl="http://downloads.prometheus-group.com/delayed/rules/modsec/"
# TODO: introduce that url
#baseUrl="http://updates.atomicorp.com/channels/rules/delayed/modsec/"

for theRule in $listOfRules ; do
  # ensure that theRule file is present
  touch ${theRule}
  /usr/bin/wget -t 30 -O ${theRule}.1 -q ${baseUrl}${theRule}
  if [ `md5sum ${theRule} | cut -d " " -f1` != `md5sum ${theRule}.1 | cut -d " " -f1` ] ; then
    /bin/mv ${theRule} ${theRule}.bak
    /bin/mv ${theRule}.1 ${theRule}
    UPDATED=`expr $UPDATED + 1`
  else
    /bin/rm -f ${theRule}.1
  fi
done

if [ "$UPDATED" -gt "0" ]; then
  # check config before reloading
  $APACHEINITD configtest
  if [ $? -eq 0 ]; then
    $APACHEINITD reload
    $APACHEINITD status
    if [ $? -eq 0 ]; then
      exit 0
    fi
  fi

  echo "error. Configtest failed"
  #roll back everything
  for theRule in $listOfRules ; do
    echo -n "Rolling back ${theRule}"
    /bin/mv ${theRule} ${theRule}.new
    /bin/mv ${theRule}.bak ${theRule}
    echo "rolled back ok."
  done

  $APACHEINITD configtest
  if [ $? -eq 0 ]; then
    # try starting httpd again
    $APACHEINITD reload

    # did that fix the problem?
    $APACHEINITD status
    if [ $? -eq 0 ]; then
      echo "That did the trick."
      # still non zero exitcode as we can't update
      exit 1
    else
      echo "Fatal: Apache server is not running. Server needs attention!"
    fi
  else
    echo "Fatal: Apache configtest is still failing, Server needs attention!"
  fi
  exit 999
fi
