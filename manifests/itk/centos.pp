class mod_security::itk::centos inherits mod_security::centos {
  # this is a bit ugly but currently we can define the SecDir only globally
  File['/var/www/modsecurity_data']{
    mode => 0666,
  }
}
