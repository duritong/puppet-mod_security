class mod_security::base {

  include apache

  package { 'mod_security':
    alias   => 'mod_security',
    ensure  => installed,
    require => Package['apache'],
    notify  => Service['apache'],
  }

  $config_dir = $operatingsystem ? {
    centos  => "${apache::centos::config_dir}/modsecurity.d",
    debian  => "${apache::debian::config_dir}/modsecurity.d",
    default => '/etc/apache2/conf.d',
  }

  file { 'mod_security_config_dir':
    path    => $config_dir,
    ensure  => directory,
    require => Package['mod_security'],
    owner   => 'root', group => 0, mode => '0755';
  }

  # Use rule set from Atomic Secured Linux and update them every day
  # See : http://www.gotroot.com/mod_security+rules

  apache::config::file { 'mod_security_asl.conf': }
  file { 'mod_security_asl_config_dir':
    path    => "${config_dir}/asl",
    require => Package['mod_security'],
  }
  file { 'mod_security_asl_update_script':
    path    => '/usr/local/bin/mod_security_asl_update.sh',
    require => File['mod_security_asl_config_dir'],
  }
  cron { 'mod_security_asl_update':
    user => 'root',
    require => File['mod_security_asl_update_script'],
  }
  if ($mod_security_asl_ruleset == true) {

    File['mod_security_asl_config_dir']{
      ensure  => directory,
      owner   => 'root', group => 0, mode => '0755',
    }

    File['mod_security_asl_update_script']{
      ensure  => present,
      source  => [ "puppet:///modules/site-mod_security/scripts/$operatingsystem/mod_security_asl_update.sh",
                   "puppet:///modules/site-mod_security/scripts/mod_security_asl_update.sh",
                   "puppet:///modules/mod_security/scripts/$operatingsystem/mod_security_asl_update.sh",
                   "puppet:///modules/mod_security/scripts/mod_security_asl_update.sh" ],
      owner   => 'root',
      group   => 0,
      mode    => '0700',
    }

    exec { 'mod_security_asl_initialize':
      command => '/usr/local/bin/mod_security_asl_update.sh',
      creates => "${config_dir}/asl/sql.txt",
      require => File['mod_security_asl_update_script'],
    }

    Cron['mod_security_asl_update']{
      command => '/usr/local/bin/mod_security_asl_update.sh',
      ensure  => present,
      hour    => 3,
      minute  => 39,
    }

    Apache::Config::File['mod_security_asl.conf']{
      ensure  => present,
      content => "<IfModule mod_security2.c>\ninclude modsecurity.d/asl/*.conf\n</IfModule>",
    }

  }
  else {
    File['mod_security_asl_config_dir']{
      ensure  => absent,
      recurse => true,
      force   => true,
      purge   => true,
    }

    File['mod_security_asl_update_script']{
      ensure  => absent,
    }

    Cron['mod_security_asl_update']{
      ensure  => absent,
    }
    Apache::Config::File['mod_security_asl.conf']{
      ensure => absent,
    }
  }

  # Automatically clean vhost mod_security logs

  file{'mod_security_logclean_script':
      path    => '/usr/local/bin/mod_security_logclean.sh',
  }
  cron{'mod_security_logclean':
      user    => root,
      require => File['mod_security_logclean_script'],
  }
  if ($mod_security_logclean == true) {

    File['mod_security_logclean_script']{
      ensure  => present,
      source  => [ "puppet:///modules/site-mod_security/scripts/$operatingsystem/mod_security_logclean.sh",
                   "puppet:///modules/site-mod_security/scripts/mod_security_logclean.sh",
                   "puppet:///modules/mod_security/scripts/$operatingsystem/mod_security_logclean.sh",
                   "puppet:///modules/mod_security/scripts/mod_security_logclean.sh" ],
      owner   => 'root',
      group   => 0,
      mode    => '0700',
    }

    Cron['mod_security_logclean']{
      ensure  => present,
      command => '/usr/local/bin/mod_security_logclean.sh',
      hour    => 3,
      minute  => 23,
    }

  }
  else {

    File['mod_security_logclean_script']{
      ensure  => absent,
    }

    Cron['mod_security_logclean']{
      ensure  => absent,
    }

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

