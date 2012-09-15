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

  package{'mod_security_crs': }
  if $mod_security::crs_ruleset {
    Package['mod_security_crs']{
      ensure => present,
    }
  } else {
    Package['mod_security_crs']{
      ensure => absent,
    }
  }

  package{'mod_security_crs-extras': }
  if $mod_security::crs_extras_ruleset {
    Package['mod_security_crs-extras']{
      ensure => present,
    }
  } else {
    Package['mod_security_crs-extras']{
      ensure => absent,
    }
  }
}
