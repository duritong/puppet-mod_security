# 2008 - admin(at)immerda.ch
# Adapated by Puzzle ITC
# License: GPLv3
class mod_security(
  $log_clean_days_to_keep = 5,
  $asl_ruleset            = false,
  $crs_ruleset            = true,
  $crs_extras_ruleset     = false,
) {
  include ::apache
  $config_dir = "${apache::config_dir}/modsecurity.d"

  case $::operatingsystem {
    centos: { include mod_security::centos }
    default: { include mod_security::base }
  }
}
