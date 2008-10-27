#
# mod_security module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

# modules_dir { \"mod_security\": }

class mod_security {
    include mod_security::base
}

class mod_security::base {
    package{'mod_security':
        ensure => present,
    }
    service{mod_security:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[mod_security],
    }
}
