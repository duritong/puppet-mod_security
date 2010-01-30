class mod_security::base {

  include apache

  package { 'mod_security':
    alias   => 'mod_security',
    ensure  => installed,
    notify  => Service[apache],
  }

  $config_dir = $operatingsystem ? {
    centos  => "${apache::centos::config_dir}/modsecurity.d",
    debian  => "${apache::debian::config_dir}/modsecurity.d",
    default => '/etc/apache2/conf.d',
  }

  file { 'mod_security_config_dir':
    path    => $config_dir,
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  # Use rule set from Atomic Secured Linux and update them every day
  # See : http://www.gotroot.com/mod_security+rules

  apache::config::file { 'mod_security_asl.conf': }
  if ($mod_security_asl_ruleset == true) {

    file { 'mod_security_asl_config_dir':
      path    => "${config_dir}/asl",
      ensure  => directory,
      owner   => 'root',
      group   => 0,
      mode    => '0755',
    }

    file { 'mod_security_asl_update_script':
      ensure  => present,
      path    => '/usr/local/bin/mod_security_asl_update.sh',
      source  => [ "puppet://${server}/modules/site-mod_security/scripts/$operatingsystem/mod_security_asl_update.sh",
                   "puppet://${server}/modules/site-mod_security/scripts/mod_security_asl_update.sh",
                   "puppet://${server}/modules/mod_security/scripts/$operatingsystem/mod_security_asl_update.sh",
                   "puppet://${server}/modules/mod_security/scripts/mod_security_asl_update.sh" ],
      owner   => 'root',
      group   => 0,
      mode    => '0700',
    }

    exec { 'mod_security_asl_initialize':
      command => '/usr/local/bin/mod_security_asl_update.sh',
      creates => "${config_dir}/asl/sql.txt",
      require => File[ [ 'mod_security_asl_config_dir', 'mod_security_asl_update_script' ] ],
    }

    cron { 'mod_security_asl_update':
      ensure  => present,
      command => '/usr/local/bin/mod_security_asl_update.sh',
      user    => 'root',
      hour    => 3,
      minute  => 39,
    }

    Apache::Config::File['mod_security_asl.conf']{
      ensure  => present,
      content => 'include modsecurity.d/asl/*.conf',
    }

  }
  else {

    file { 'mod_security_asl_config_dir':
      path    => "${config_dir}/asl",
      ensure  => absent,
      recurse => true,
      force   => true,
    }

    file { 'mod_security_asl_update_script':
      ensure  => absent,
      path    => '/usr/local/bin/mod_security_asl_update.sh',
    }

    cron { 'mod_security_asl_update':
      ensure  => absent,
      user    => root,
    }
    Apache::Config::File['mod_security_asl.conf']{
      ensure => absent,
    }
  }

  # Automatically clean vhost mod_security logs

  if ($mod_security_logclean == true) {

    file { 'mod_security_logclean_script':
      ensure  => present,
      path    => '/usr/local/bin/mod_security_logclean.sh',
      source  => [ "puppet://${server}/modules/site-mod_security/scripts/$operatingsystem/mod_security_logclean.sh",
                   "puppet://${server}/modules/site-mod_security/scripts/mod_security_logclean.sh",
                   "puppet://${server}/modules/mod_security/scripts/$operatingsystem/mod_security_logclean.sh",
                   "puppet://${server}/modules/mod_security/scripts/mod_security_logclean.sh" ],
      owner   => 'root',
      group   => 0,
      mode    => '0700',
    }

    cron { 'mod_security_logclean':
      ensure  => present,
      command => '/usr/local/bin/mod_security_logclean.sh',
      user    => 'root',
      hour    => 3,
      minute  => 23,
    }

  }
  else {

    file { 'mod_security_logclean_script':
      ensure  => absent,
      path    => '/usr/local/bin/mod_security_logclean.sh',
    }

    cron { 'mod_security_logclean':
      ensure  => absent,
      user    => root,
    }

  }

}

