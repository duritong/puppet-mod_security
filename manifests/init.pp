# modules/apache/manifests/modules/mod_security.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class mod_security {
    case $operatingsystem {
        gentoo: { include mod_security::gentoo }
        default: { include mod_security::base }
    }
}

class mod_security::base {
    #mod_unique_id is needed for mod_security
    include mod_unique_id

    package{mod_security:
        ensure => installed,
        notify => Service[apache],
    }

    file{custom_rules:
        path => "/etc/apache2/modules.d/mod_security/Zcustom_rules/",
        source => "puppet://$server/mod_security/custom_rules/",
        recurse => true,
        owner => root,
        group => 0,
        mode => 644,
        require => Package[mod_security],
        notify => Service[apache],
    }
}

class mod_security::gentoo inherits mod_security::base {
    Package[mod_security]{
        category => 'www-apache',
    }

    file{"/etc/apache2/modules.d/99_mod_security.conf":
        source => "puppet://$server/mod_security/configs/gentoo/99_mod_security.conf",
        owner => root,
        group => 0,
        mode => 644,
        require => Package[mod_security],
        notify => Service[apache],
    }
}


