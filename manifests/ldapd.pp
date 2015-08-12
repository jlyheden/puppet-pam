# == Class: pam::ldapd
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
# [*source*]
#   Path to Puppet source file for Debuntu pam-auth-update file
#   Valid values: <tt>puppet:///modules/mymodule/myfile</tt>
#
# [*content*]
#   Content to populate pam-auth-update file with
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'pam::ldap': }
#
# * Uninstalling the software
#   class { 'pam::ldap': ensure => absent }
#
class pam::ldapd (
  $ensure       = 'UNDEF',
  $autoupgrade  = 'UNDEF',
  $source       = 'UNDEF',
  $content      = 'UNDEF'
) {

  include pam
  include pam::params

  # puppet 2.6
  $ensure_real = $ensure ? {
    'UNDEF' => $pam::params::ensure,
    default => $ensure
  }
  $autoupgrade_real = $autoupgrade ? {
    'UNDEF' => $pam::params::autoupgrade,
    default => $autoupgrade
  }
  $source_real = $source ? {
    'UNDEF' => $pam::params::pam_auth_update_ldap_source,
    default => $source
  }
  $content_real = $content ? {
    'UNDEF'   => $pam::params::pam_auth_update_ldap_template ? {
      ''      => '',
      default => template($pam::params::pam_auth_update_ldap_template)
    },
    default   => $content
  }

  # Input validation
  validate_re($ensure_real, $pam::params::valid_ensure_values)
  validate_bool($autoupgrade_real)
  if $source_real != '' and $content_real != '' {
    fail('Only one of parameters source and content can be set')
  }

  # Manages automatic upgrade behavior
  if $ensure_real == 'present' and $autoupgrade_real == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure_real
  }

  # Debuntu uses pam-auth-update to build pam configuration
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      if $source_real != '' {
        File['pam_auth_update_ldap_file'] {
          source  => $source_real
        }
      } elsif $content_real != '' {
        File['pam_auth_update_ldap_file'] {
          content => $content_real
        }
      }
      file { 'pam_auth_update_ldap_file':
        ensure  => $ensure_real,
        path    => $pam::params::pam_auth_update_ldap_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['pam_auth_update'],
        require => Package['pamldapd']
      }
    }
    default: { }
  }

  package { 'pamldapd':
    ensure => $ensure_package,
    name   => $pam::params::ldapd_package
  }

}
