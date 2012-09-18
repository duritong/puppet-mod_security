class mod_security::itk_plus::centos inherits mod_security::centos {
  Apache::Config::Global['mod_security.conf']{
    source  => [  "puppet:///modules/site_mod_security/itk_plus/${::fqdn}/mod_security.conf",
                  "puppet:///modules/site_mod_security/itk_plus/${::domain}/mod_security.conf",
                  'puppet:///modules/site_mod_security/itk_plus/mod_security.conf',
                  "puppet:///modules/mod_security/itk_plus/${::operatingsystem}/mod_security.conf" ],

  }
}
