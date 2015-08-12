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
# [*force_pam_auth_update*]
#   Only applies to Debian/Ubuntu. If pam-auth-update
#   should force the configuration and overwrite local
#   changes.
#   Valid values: <tt>boolean</tt>
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
# * Ubuntu LTS 10.04, 12.04
#
class pam (
  $ensure                 = 'UNDEF',
  $autoupgrade            = 'UNDEF',
  $force_pam_auth_update  = false
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

  validate_re($ensure_real, $pam::params::valid_ensure_values)
  validate_bool($autoupgrade_real)

  # Manages automatic upgrade behavior
  if $ensure_real == 'present' and $autoupgrade_real == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure_real
  }

  package { 'pam':
    ensure => $ensure_package,
    name   => $pam::params::package
  }

  case $force_pam_auth_update {
    true: {
      $pam_auth_update_cmd = 'pam-auth-update --force'
    }
    false: {
      $pam_auth_update_cmd = 'pam-auth-update'
    }
    default: {
      fail("Unsupported force_pam_auth_update value ${::force_pam_auth_update}. Valid values: true, false")
    }
  }

  exec { 'pam_auth_update':
    command     => $pam_auth_update_cmd,
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    refreshonly => true,
    require     => Package['pam']
  }

}
