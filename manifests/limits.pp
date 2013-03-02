# == Class: pam::limits
#
# This module manages the pam_limits.so module for PAM.
# The pam_limits PAM module sets limits on the system
# resources that can be obtained in a user-session.
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>
#
# [*change_uid*]
#   Change real uid to the user for who the limits are set up.
#   Use this option if you have problems like login not forking
#   a shell for user who has no processes. Be warned that something
#   else may break when you do this.
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*conf*]
#   Indicate an alternative limits.conf style configuration file
#   to override the default
#   Valid values: <tt>/path/to/limits.conf</tt>
#
# [*conf_d*]
#   Path to limits.d directory containing individual conf files
#   It is not clear in the man page of pam_limits how this
#   directory is determined so until further testing has been
#   done this should probably be used with caution (as
#   in - providing another value rather than default).
#   Valid values: <tt>/path/to/limits.d</tt>
#
# [*purge_conf_d*]
#   Determines if Puppet should discard any foreign files
#   found in the conf_d directory
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*debug*]
#   Print debug information
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*noaudit*]
#   Do not report logins from disallowed hosts and ttys to the audit subsystem
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*utmp_early*]
#   Some broken applications actually allocate a utmp entry for
#   the user before the user is admitted to the system. If some
#   of the services you are configuring PAM for do this, you can
#   selectively use this module argument to compensate for this
#   behavior and at the same time maintain system-wide consistency
#   with a single limits.conf file.
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*source*]
#   Path to static Puppet file to use
#   Valid values: <tt>puppet:///modules/mymodule/path/to/file.conf</tt>
#
# [*template*]
#   Path to ERB puppet template file to use
#   Valid values: <tt>mymodule/path/to/file.conf.erb</tt>
#
# [*source_d*]
#   Path to source directory for conf_d
#   Valid values: <tt>puppet:///modules/mymodules/path/to/dir</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'pam::limits': }
#
# * Uninstalling the software
#   class { 'pam::limits': ensure => absent }
#
# === Supported platforms
#
# This module has not been tested
#
# To add support for other platforms, edit the params.pp file and provide
# settings for that platform.
#
class pam::limits (
  $ensure       = 'present',
  $change_uid   = 'UNDEF',
  $conf         = 'UNDEF',
  $conf_d       = 'UNDEF',
  $purge_conf_d = 'UNDEF',
  $debug        = 'UNDEF',
  $noaudit      = 'UNDEF',
  $utmp_early   = 'UNDEF',
  $source       = 'UNDEF',
  $template     = 'UNDEF',
  $source_d     = 'UNDEF'
) {

  include pam
  include pam::params

  # puppet 2.6 compatibility
  $change_uid_real = $change_uid ? {
    'UNDEF' => $pam::params::limits_change_uid,
    default => $change_uid
  }
  $conf_real = $conf ? {
    'UNDEF' => $pam::params::limits_conf,
    default => $conf
  }
  $conf_d_real = $conf_d ? {
    'UNDEF' => $pam::params::limits_conf_d,
    default => $conf_d
  }
  $purge_conf_d_real = $purge_conf_d ? {
    'UNDEF' => $pam::params::limits_purge_conf_d,
    default => $purge_conf_d
  }
  $debug_real = $debug ? {
    'UNDEF' => $pam::params::limits_debug,
    default => $debug
  }
  $noaudit_real = $noaudit ? {
    'UNDEF' => $pam::params::limits_noaudit,
    default => $noaudit
  }
  $utmp_early_real = $utmp_early ? {
    'UNDEF' => $pam::params::limits_utmp_early,
    default => $utmp_early
  }
  $source_real = $source ? {
    'UNDEF' => $pam::params::limits_source,
    default => $source,
  }
  $template_real = $template ? {
    'UNDEF' => $pam::params::limits_template,
    default => $template
  }
  $source_d_real = $source_d ? {
    'UNDEF' => $pam::params::limits_source_d,
    default => $source_d
  }

  # Input validation
  $valid_ensure_values = [ 'present', 'absent' ]
  validate_re($ensure, $valid_ensure_values)
  validate_bool($debug_real)
  validate_bool($noaudit_real)
  validate_bool($change_uid_real)
  validate_bool($utmp_early_real)
  validate_bool($purge_conf_d_real)

  $manage_file_source = $source_real ? {
    ''        => undef,
    default   => $source_real,
  }
  $manage_file_template = $template_real ? {
    ''        => undef,
    default   => template($template_real),
  }

  # Sanitized string builder variables
  # for pam_access.so options
  $conf_entry = " conf=${conf_real}"
  $change_uid_entry = $change_uid_real ? {
    true  => ' change_uid',
    false => '',
  }
  $debug_entry = $debug_real ? {
    true  => ' debug',
    false => '',
  }
  $noaudit_entry = $noaudit_real ? {
    true  => ' noaudit',
    false => '',
  }
  $utmp_early_entry = $utmp_early_real ? {
    true  => ' utmp_early',
    false => ''
  }
  $pam_limits_parameters = "${conf_entry}${change_uid_entry}${debug_entry}${noaudit_entry}${utmp_early_entry}"

  # Debuntu uses pam-auth-update to build pam configuration
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      file { 'pam_auth_update_limits_file':
        ensure  => $ensure,
        path    => $pam::params::pam_auth_update_limits_file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($pam::params::pam_auth_update_limits_tmpl),
        notify  => Exec['pam_auth_update']
      }
    }
    default: {
      fail("Unsupported operatingsystem ${::operatingsystem}")
    }
  }

  case $ensure {
    present: {
      if $manage_file_template != undef {
        File['pam_limits_conf'] {
          content => $manage_file_template
        }
      } else {
        File['pam_limits_conf'] {
          source  => $manage_file_source
        }
      }
      if $purge_conf_d_real {
        File['pam_limits_conf_d'] {
          purge   => true,
          force   => true,
          recurse => true
        }
      }
      if $source_d_real != undef {
        File['pam_limits_conf_d'] {
          source  => $source_d_real
        }
      }
      file { 'pam_limits_conf':
        ensure  => present,
        path    => $conf_real,
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
      }
      file { 'pam_limits_conf_d':
        ensure  => directory,
        path    => $conf_d_real,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
      File <| tag == 'pam_limits_conf_d' |>
    }
    default: {
      # Don't know how to best unmanage the limits.conf file
      # This section would 'reset' it in case it
      # finds # MANAGED BY PUPPET in the file
      exec { 'insert_blank_access_conf_file':
        command => "echo '## UNMANAGED FILE' > ${conf_real}",
        onlyif  => "grep '^# MANAGED BY PUPPET ${conf_real} >/dev/null",
        path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ]
      }
    }
  }

}
