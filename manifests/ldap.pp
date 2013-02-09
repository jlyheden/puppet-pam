# == Class: pam::ldap
#
# This module manages the LDAP module for PAM. This allows the
# server to authenticate via directory services such as Openldap
# and Active Directory
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
#   class { 'pam::ldap': }
#
# * Uninstalling the software
#   class { 'pam::ldap': ensure => absent }
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
class pam::ldap ( $ensure = $pam::params::ensure, $autoupgrade = $pam::params::autoupgrade ) inherits pam::params {

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
        Package['pamldap'] { ensure => latest }
      } else {
        Package['pamldap'] { ensure => present }
      }
    }
    
    # If software should be uninstalled
    absent,purge: {
      Package['pamldap'] { ensure => $ensure }
    }
    
    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure}")
    }
  }
  
  package { 'pamldap':
    name    => $pam::params::ldap_package
  }

}
