# centos specific things
class mod_security::centos inherits mod_security::base {
  if versioncmp($acts['os']['release']['major'],'7') < 0 {
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

  # comment out an unwanted rule
  # 200003 : broken multipart upload boundaries
  if versioncmp($facts['os']['release']['major'],'6') > 0 {
    Package<| title == 'mod_security' |> -> exec{'comment_out_rule_id_200003':
      command => 'sed -i -e "s/ \(SecRule MULTIPART_UNMATCHED_BOUNDARY\)/ #\1/" -e "s/ \(\"id:\'200003\)/ #\1/" /etc/httpd/conf.d/mod_security.conf',
      onlyif  => 'grep -qE " (SecRule MULTIPART_UNMATCHED_BOUNDARY|\"id:\'200003)" /etc/httpd/conf.d/mod_security.conf',
      notify  => Service['apache'],
    }
  }
}
