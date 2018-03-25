# base setup of mode_security
class mod_security::base {

  package{'mod_security':
    ensure  => installed,
    require => Package['apache'],
    notify  => Service['apache'],
  }

  file{'mod_security_config_dir':
    ensure  => directory,
    path    => $mod_security::config_dir,
    require => Package['mod_security'],
    owner   => 'root',
    group   => 0,
    mode    => '0755';
  }

  # Automatically clean vhost mod_security logs
  file{'/usr/local/sbin/mod_security_logclean.sh':
    source  => "puppet:///modules/mod_security/scripts/mod_security_logclean.sh",
    owner   => 'root',
    group   => 0,
    mode    => '0700',
  }
  file{'/etc/cron.daily/mod_security_logclean.sh': }
  if $mod_security::log_clean_days_to_keep {
    File['/etc/cron.daily/mod_security_logclean.sh']{
      owner    => 'root',
      group    => 0,
      mode     => '0700',
      content  => "#!/bin/bash\n/usr/local/sbin/mod_security_logclean.sh ${mod_security::log_clean_days_to_keep}\n",
    }
  } else {
    File['/etc/cron.daily/mod_security_logclean.sh']{
      ensure  => absent,
    }
  }
}

