class mod_security::itk inherits mod_security::base {
  case $operatingsystem {
    default: { include mod_security::itk::base }
  }
}
