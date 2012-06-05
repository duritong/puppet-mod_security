# modules/apache/manifests/modules/mod_security.pp
# 2008 - admin(at)immerda.ch
# Adapated by Puzzle ITC
# License: GPLv3

class mod_security {
  case $::operatingsystem {
    centos: { include mod_security::centos }
    debian: { include mod_security::debian }
    default: { include mod_security::base }
  }
}
