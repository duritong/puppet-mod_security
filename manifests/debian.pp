class mod_security::debian inherits mod_security::base {
  Package['mod_security'] {
    name => 'libapache-mod-security'
  }

  apache::config::file { 'mod_security.conf':
    ensure  => present,
    content => 'include modsecurity.d/*.conf',
  }
  
  # since version 2.5 we need to define a SecDataDir
  file{'/var/www/modsecurity_data':
    ensure => directory,
    require => Package['mod_security'],
    owner => 'www-data', group => 'www-data', mode => 0640;
  }
  file{"${config_dir}/sec_data_dir.conf":
    content => "SecDataDir /var/www/modsecurity_data\n",
    require => File['/var/www/modsecurity_data'],
    notify => Service['apache'],
    owner => root, group => 0, mode => 0644;
  }
}
