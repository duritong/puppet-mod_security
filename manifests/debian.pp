class mod_security::debian inherits mod_security::base {
  Package['mod_security'] {
    name => 'libapache-mod-security'
  }

  apache::config::file { 'mod_security.conf':
    ensure  => present,
    content => 'include modsecurity.d/*.conf',
  }

  File['/var/www/modsecurity_data'] {
    owner => 'www-data',
    group => 'www-data',
  }
}
