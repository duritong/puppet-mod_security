class mod_security::itk inherits mod_security {
  case $::operatingsystem {
    default: { include mod_security::itk::base }
  }
}
