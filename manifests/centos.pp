class mod_security::centos inherits mod_security::base {
  apache::config::global{'mod_security.conf':
    source => "modules/mod_security/normal/${::operatingsystem}/mod_security.conf",
    require => Package['mod_security'],
    notify => Service['apache'],
  }
  file{'/etc/httpd/modsecurity.d/customrules/optional_rules.conf':
    content => "Include modsecurity.d/optional_rules/*.conf\n",
    ensure => $mod_security_optional_rules ? {
                true => 'present',
                default => 'absent'
    },
    require => Package['mod_security'],
    notify => Service['apache'],
    owner => root, group => 0, mode => 0644;
  }
}
