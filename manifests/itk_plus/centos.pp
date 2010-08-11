class mod_security::itk_plus::centos {
  apache::config::global{'mod_security.conf':
    source => "modules/mod_security/itk_plus/${operatingsystem}/mod_security.conf",
  }
}
