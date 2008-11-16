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

APACHEINITD="/etc/init.d/httpd"
MODSECPATH="/etc/httpd/modsecurity.d/customrules"

##########################################################################
######### you probably don't need to change anything below here ##########
##########################################################################

# internal
PID=`cat ${APACHEPID}`
UPDATED=0

echo -n "Changing PWD: "
cd ${MODSECPATH}
echo `pwd`


# generic by skyhorse
# updated by Puzzle ITC


listOfRules="apache2-rules blacklist blacklist2 exclude jitp recons rootkits rules useragents"
baseUrl="http://www.gotroot.com/downloads/ftp/mod_security/2.0/apache2/"

for theRule in $listOfRules
do
echo -n "Updating $theRule: "
/usr/bin/wget -t 30 -O ${theRule}.conf.1 -q ${baseUrl}${theRule}.conf
if [ `md5sum ${theRule}.conf | cut -d " " -f1` != `md5sum ${theRule}.conf.1 | cut -d " " -f1` ] ; then

	/bin/mv ${theRule}.conf ${theRule}.conf.bak
	/bin/mv ${theRule}.conf.1 ${theRule}.conf
	UPDATED=`expr $UPDATED + 1`
	echo "ok."
else
	echo "allready up to date."
	/bin/rm -f ${theRule}.conf.1
fi
done

# try restart
if [ "$UPDATED" -gt "0" ]; then
	echo -n "Restarting apache: "
	$APACHEINITD configtest 
    $configtest=$?
    if [ "$configtest" -eq "0" ]; then 
       $APACHEINITD restart
    	# did it work?
	    if `$APACHEINITD status`; then
		    echo "Apache restarted ok."
    		exit 0
	    fi
	    echo "error. Apache not running."
    fi

	#roll back everything
	for theRule in $listOfRules
	do
	echo -n "Rolling back ${theRule}"
	/bin/mv ${theRule}.conf ${theRule}.conf.new
	/bin/mv ${theRule}.conf.bak ${theRule}.conf
	echo "rolled back ok."
	done
	
    $APACHEINITD configtest 
    $configtest=$?
    if [ "$configtest" -eq "0" ]; then
	    # try starting httpd again
    	$APACHEINITD restart
	
    	# did that fix the problem?
	    if `$APACHEINITD status`; then
		    echo "That did the trick."
    		exit 0
	    fi
    else
        echo "Fatal: Apache configtest is till failing, Server needs attention!"
    fi
	echo "Fatal: Apache still not running! Run apachectl -t to find the error."
	exit 999
fi
