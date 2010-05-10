class mod_security::itk::base inherits mod_security::base {
  # this is a bit ugly but currently we can define the SecDir only globally
  # see : https://www.modsecurity.org/tracker/browse/MODSEC-149
  File['/var/www/modsecurity_data']{
    mode => 0666,
  }
}
