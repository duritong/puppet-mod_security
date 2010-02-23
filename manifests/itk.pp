class mod_security::itk inherits mod_security {
  case $operatingsystem {
    centos: { include mod_security::itk::centos }
  }
}
