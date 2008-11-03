# modules/apache/manifests/modules/mod_security.pp
# 2008 - admin(at)immerda.ch
# Adapated by Puzzle ITC
# License: GPLv3

class mod_security {
    include mod_security::base
}

# very centos stylish at the moment
class mod_security::base {
    package{'mod_security':
        ensure => installed,
        notify => Service[apache],
    }

    file{'/etc/httpd/modsecurity.d/modsecurity_localrules.conf':
        content => 'Include modsecurity.d/customrules/*.conf',
        require => Package['mod_security'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/etc/httpd/modsecurity.d/customrules':
        ensure => directory,
        require => Package[mod_security],
        owner => root, group => 0, mode => 0755;
    }

    file{'/etc/cron.d/modsec.sh':
        source => "puppet://$server/mod_security/cron/modsec.sh",
        notify => Exec['update_modsec_rules'], 
        require => File['/etc/httpd/modsecurity.d/customrules'],
        owner => root, group => 0, mode => 0755;
    }
    exec{'update_modsec_rules':
        command => '/etc/cron.d/modsec.sh',
        refreshonly => true,
    }
}
