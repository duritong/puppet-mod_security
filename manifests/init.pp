# 2008 - admin(at)immerda.ch
# Adapated by Puzzle ITC
# License: GPLv3

class mod_security(
  $log_clean = hiera('mod_security_log_clean',false),
  $asl_ruleset = hiera('mod_security_asl_ruleset',false),
  # so far they're only available on centos
  $crs_ruleset = hiera('mod_security_crs_ruleset',false),
  $crs_extras_ruleset = hiera('mod_security_crs_extras_ruleset',false)
) {
  case $::operatingsystem {
    centos: { include mod_security::centos }
    debian: { include mod_security::debian }
    default: { include mod_security::base }
  }
}
