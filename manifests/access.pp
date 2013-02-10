# == Class: pam::access
#
# This module manages the pam_access.so module for PAM.
# It grants the ability to allow or deny certain users
# or groups to authenticate to the system.
#
# If you use this class without passing an explicit
# access.conf configuration file via the template
# or source parameter, it is recommended to complement
# access via the define pam::access::entry
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*accessfile*]
#   Path to access.conf
#   Valid values: <tt>/path/to/access.conf</tt>
#
# [*debug*]
#   A lot of debug information is printed with syslog(3)
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*noaudit*]
#   Do not report logins from disallowed hosts and ttys to the audit subsystem
#   Valid values: <tt>true</tt>,<tt>false</tt>
#
# [*fieldsep*]
#   This option modifies the field separator character that pam_access will recognize when parsing the access configuration file
#   Valid values: <tt>sep character</tt> ex: <tt>,</tt>
#
# [*listsep*]
#   This option modifies the list separator character that pam_access will recognize when parsing the access configuration file
#   Valid values: <tt>sep character</tt> ex: <tt>,</tt>
#
# [*nodefgroup*]
#   User tokens which are not enclosed in parentheses will not be matched against the group database
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
# [*parameters*]
#   Hash variable to pass to template (if used)
#   Valid values: hash, ex:  <tt>{ 'option' => 'value' }</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'pam::access': }
#
# * Uninstalling the software
#   class { 'pam::access': ensure => absent }
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
class pam::access ( $ensure = 'present',
                    $accessfile = $pam::params::accessfile,
                    $debug = $pam::params::debug,
                    $noaudit = $pam::params::noaudit,
                    $fieldsep = $pam::params::fieldsep,
                    $listsep = $pam::params::listsep,
                    $nodefgroup = $pam::params::nodefgroup,
                    $source = $pam::params::access_source,
                    $template = $pam::params::access_template,
                    $parameters = {} ) inherits pam::params {

  include pam

  # Input validation
  validate_re($ensure, [ 'present', 'absent' ])
  validate_hash($parameters)

  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }
  $manage_file_content = $template ? {
    ''        => undef,
    default   => template($template),
  }

  # Sanitized string builder variables
  # for pam_access.so options
  $listsep_entry_real = $listsep ? {
    undef   => ' ',
    default => $listsep
  }
  $accessfile_entry = $accessfile ? {
    undef   => '',
    ''      => '',
    default => " accessfile=${accessfile}"
  }
  $debug_entry = $debug ? {
    true    => ' debug',
    false   => '',
    default => fail("Unsupported debug value ${debug}")
  }
  $noaudit_entry = $noaudit ? {
    true    => ' noaudit',
    false   => '',
    default => fail("Unsupported noaudit value ${noaudit}")
  }
  $fieldsep_entry = $fieldsep ? {
    undef   => '',
    ''      => '',
    default => " fieldsep='${fieldsep}'"
  }
  $listsep_entry = $listsep ? {
    undef   => '',
    ''      => '',
    default => " listsep='${listsep}'"
  }
  $nodefgroup_entry = $nodefgroup ? {
    true    => ' nodefgroup',
    false   => '',
    default => fail("Unsupported nodefgroup value ${nodefgroup}")
  }
  $pam_access_parameters = "${accessfile_entry}${debug_entry}${noaudit_entry}${fieldsep_entry}${listsep_entry}${nodefgroup_entry}"

  # Ubuntu uses pam-auth-update to build pam configuration
  case $::lsbdistcodename {
    lucid: {
      file { 'pam_auth_update_access_file':
        ensure  => $ensure,
        path    =>$pam::params::pam_auth_update_access_file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($pam::params::pam_auth_update_access_tmpl),
        notify  => Exec['pam_auth_update']
      }
    }
    default: {
      fail("Unsupported distribution ${::lsbdistcodename}")
    }
  }

  case $ensure {
    present: {

      # use fragments if file source not provided
      if $manage_file_source == undef and $manage_file_template == undef {
        concat { $accessfile:
          owner   => 'root',
          group   => 'root',
          mode    => '0644'
        }
        concat::fragment { '10_pam_access_conf_head':
          target  => $accessfile,
          content => "# MANAGED BY PUPPET\n",
          order   => '10'
        }
        concat::fragment { '90_pam_access_conf_foot':
          target  => $accessfile,
          content => "-:ALL${listsep_entry_real}EXCEPT${listsep_entry_real}root:ALL\n",
          order   => '90'
        }
        Concat::Fragment <| tag == 'pam_access' |>
      # otherwise manage file as usual
      } else {
        file { $accessfile:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $manage_file_template,
          source  => $manage_file_source
        }
      }

    }
    default: {} # leave files as is in any other case
  }

}
