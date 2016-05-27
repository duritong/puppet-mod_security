# centos specific things
class mod_security::centos inherits mod_security::base {
  if versioncmp($::operatingsystemmajrelease,'7') < 0 {
    apache::config::global{'mod_security.conf':
      source  => [  "puppet:///modules/site_mod_security/normal/${::fqdn}/mod_security.conf",
                    "puppet:///modules/site_mod_security/normal/${::domain}/mod_security.conf",
                    "puppet:///modules/site_mod_security/normal/${::operatingsystem}.${::operatingsystemmajrelease}/mod_security.conf",
                    "puppet:///modules/site_mod_security/normal/${::operatingsystem}/mod_security.conf",
                    "puppet:///modules/site_mod_security/normal/mod_security.conf",
                    "puppet:///modules/mod_security/normal/${::operatingsystem}/mod_security.conf" ],
      require => Package['mod_security'],
      notify => Service['apache'],
    }
    # since version 2.5 we need to define a SecDataDir
    file{
      '/var/www/modsecurity_data':
        ensure  => directory,
        require => Package['mod_security'],
        owner   => apache,
        group   => apache,
        mode    => '0640';
      "${mod_security::config_dir}/sec_data_dir.conf":
        content => "SecDataDir /var/www/modsecurity_data\n",
        require => File['/var/www/modsecurity_data'],
        notify  => Service['apache'],
        owner   => root,
        group   => 0,
        mode    => '0644';
    }
  }
}
