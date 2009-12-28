class mod_security::debian inherits mod_security::base {
  Package['mod_security'] {
    name => 'libapache-mod-security'
  }
}
