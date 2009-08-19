# very centos stylish at the moment
class mod_security::base {
    package{'mod_security':
        ensure => installed,
        notify => Service[apache],
    }

    file{'/etc/httpd/modsecurity.d/modsecurity_localrules.conf':
        content => "Include modsecurity.d/customrules/*.conf\n",
        require => Package['mod_security'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/etc/httpd/modsecurity.d/customrules':
        ensure => directory,
        require => Package[mod_security],
        owner => root, group => 0, mode => 0755;
    }

    file{'/etc/cron.daily/modsec.sh':
        source => "puppet://$server/mod_security/cron/modsec.sh",
        notify => Exec['update_modsec_rules'],
        require => File['/etc/httpd/modsecurity.d/customrules'],
        owner => root, group => 0, mode => 0755;
    }
    exec{'update_modsec_rules':
        command => '/etc/cron.daily/modsec.sh',
        refreshonly => true,
    }
}

