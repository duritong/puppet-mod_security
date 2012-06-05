class mod_security::itk_plus::centos inherits mod_security::centos {
  Apache::Config::Global['mod_security.conf']{
    source => "modules/mod_security/itk_plus/${::operatingsystem}/mod_security.conf",
  }
}
