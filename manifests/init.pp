# == Class: pam
#
# This module manages the pam. The Pluggable Authentication Module
# is a standard interface for applications to deal with authentication.
# Including this base class will normally not have any effect, rather
# custom features is provided by name spaced sub classes like pam::ldap
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*autoupgrade*]
#   If Puppet should upgrade the software automatically
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'pam': }
#
# * Uninstalling the software
#   class { 'pam': ensure => absent }
#
# === Supported platforms
#
# This module has been tested on the following platforms
# * Ubuntu LTS 10.04
#
# To add support for other platforms, edit the params.pp file and provide
# settings for that platform.
#
# === Author
#
# Johan Lyheden <johan.lyheden@artificial-solutions.com>
#
class pam ( $ensure = $pam::params::ensure, $autoupgrade = $pam::params::autoupgrade ) inherits pam::params {

  # Input validation
  validate_re($ensure,[ 'present', 'absent', 'purge' ])
  validate_bool($autoupgrade)

  # Manages automatic upgrade behavior
  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }

  case $ensure {

    # If software should be installed
    present: {
      if $autoupgrade == true {
        Package['pam'] { ensure => latest }
      } else {
        Package['pam'] { ensure => present }
      }
    }
    
    # If software should be uninstalled
    absent,purge: {
      Package['pam'] { ensure => $ensure }
    }
    
    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure}")
    }
  }
  
  package { 'pam':
    name    => $pam::params::package
  }

}
