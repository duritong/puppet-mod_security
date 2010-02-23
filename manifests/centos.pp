class mod_security::centos inherits mod_security::base {
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

  # since version 2.5 we need to define a SecDataDir
  file{'/var/www/modsecurity_data':
    ensure => directory,
    require => Package['mod_security'],
    owner => apache, group => apache, mode => 0640;
  }
  file{"${config_dir}/sec_data_dir.conf":
    content => "SecDataDir /var/www/modsecurity_data\n",
    require => File['/var/www/modsecurity_data'],
    notify => Service['apache'],
    owner => root, group => 0, mode => 0644;
  }
}
