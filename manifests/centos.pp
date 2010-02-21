class mod_security::centos inherits mod_security::base {
  file{'/etc/httpd/modsecurity.d/customrules/optional_rules.conf':
    content => "Include modsecurity.d/optional_rules/*.conf\n",
    ensure => $mod_security_optional_rules ? {
                false => 'absent',
                default => 'present'
    },
    require => Package['mod_security'],
    notify => Service['apache'],
    owner => root, group => 0, mode => 0644;
  }
}
