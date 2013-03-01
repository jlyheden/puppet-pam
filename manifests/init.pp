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
class pam (
  $ensure       = 'UNDEF',
  $autoupgrade  = 'UNDEF',
) {

  include pam::params
  # Input validation
  $ensure_real = $ensure ? {
    'UNDEF' => $pam::params::ensure,
    default => $ensure
  }
  $autoupgrade_real = $autoupgrade ? {
    'UNDEF' => $pam::params::autoupgrade,
    default => $autoupgrade
  }
  $valid_ensure_values = [ 'present', 'absent', 'purge' ]
  validate_re($ensure_real, $valid_ensure_values)
  validate_bool($autoupgrade_real)

  # Manages automatic upgrade behavior
  if $ensure_real == 'present' and $autoupgrade_real == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure_real
  }

  package { 'pam':
    ensure  => $ensure_package,
    name    => $pam::params::package
  }

  exec { 'pam_auth_update':
    command     => 'pam-auth-update',
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    refreshonly => true,
    require     => Package['pam']
  }

}
