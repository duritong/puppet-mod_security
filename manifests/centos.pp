class mod_security::centos inherits mod_security::base {
  apache::config::global{'mod_security.conf':
    source  => [  "puppet:///modules/site_mod_security/normal/${::fqdn}/mod_security.conf",
                  "puppet:///modules/site_mod_security/normal/${::domain}/mod_security.conf",
                  "puppet:///modules/site_mod_security/normal/${::operatingsystem}/mod_security.conf",
                  "puppet:///modules/site_mod_security/normal/mod_security.conf",
                  "puppet:///modules/mod_security/normal/${::operatingsystem}/mod_security.conf" ],
    require => Package['mod_security'],
    notify => Service['apache'],
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
