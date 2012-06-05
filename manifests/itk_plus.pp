class mod_security::itk_plus inherits mod_security::itk {
  case $::operatingsystem {
    centos: { include mod_security::itk_plus::centos }
  }
}
