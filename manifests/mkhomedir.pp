# == Class: pam::mkhomedir
#
# This module manages the pam_mkhomedir.so PAM module.
# By enabling this module pam can automatically create
# a users home folder if it does not already exist on
# the server, which is useful when connecting external
# user directory services.
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*umask*]
#   Home folder umask
#   Valid values: <tt>umask</tt>
#
# [*skel*]
#   Path to skeleton directory used as a template for the home directory
#   Valid values: <tt>/path/to/skel/dir</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'pam::mkhomedir': }
#
# * Uninstalling the software
#   class { 'pam::mkhomedir': ensure => absent }
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
class pam::mkhomedir (  $ensure = 'present',
                        $umask = $pam::params::umask,
                        $skel = $pam::params::skel ) inherits pam::params {

  include pam

  validate_re($ensure, [ 'present', 'absent' ])

  file { 'pam_auth_update_mkhomedir_file':
    ensure  => $ensure,
    path    => $pam::params::pam_auth_update_mkhomedir_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($pam::params::pam_auth_update_mkhomedir_tmpl),
    notify  => Exec['pam_auth_update']
  }

}
