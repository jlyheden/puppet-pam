# == Define: pam::limits::entry
#
# Manages an entry in pam_limits.so. See man 5 limits.conf
# Each define manages an individual file within the
# limits.d directory
#
# === Parameters
#
# [*domain*]
#   Can be one of the following: username, @groupname,
#   wildcard * - for default entry,
#   wildcard % - for maxlogins limit only, can also be used with %group syntax
#   Valid values: <tt>value</tt>
#
# [*type*]
#   Enforcing resource limit
#   Valid values: <tt>hard</tt>, <tt>soft</tt>, <tt>-</tt>
#
# [*item*]
#   Resource to limit
#   Valid values: man 5 limits.conf
#
# [*value*]
#   All items support the values -1, unlimited or infinity
#   indicating no limit, except for priority and nice.
#   Valid values: <tt>value</tt>
#
# [*ensure*]
#   Controls the resource definition
#   Valid values: <tt>present</tt>, <tt>absent</tt>
#
# [*priority*]
#   Determines priority in which entry will
#   be evaluated. Lower number means higher up in the
#   configuration file.
#   Valid values: numerical value
#
# [*source*]
#   Path to static puppet file resource
#   Valid values: <tt>puppet:///modules/mymodule/limits_file</tt>
#
# === Sample usage
#
# TBD
#
define pam::limits::entry (
  $domain,
  $type,
  $item,
  $value,
  $ensure   = 'present',
  $priority = '10',
  $source   = ''
) {

  include pam::params

  # Parameter validation
  $valid_ensure_values = [ 'present', 'absent' ]
  $valid_type_values = [ 'hard', 'soft', '-' ]
  $valid_item_values = [
    'core',
    'data',
    'fsize',
    'memlock',
    'nofile',
    'rss',
    'stack',
    'cpu',
    'nproc',
    'as',
    'maxlogins',
    'maxsyslogins',
    'priority',
    'locks',
    'sigpending',
    'msqqueue',
    'nice',
    'rtprio',
    'chroot'
  ]
  validate_re($ensure, $valid_ensure_values)
  validate_re($priority, '^[0-9]+$')
  validate_re($type, $valid_type_values)
  validate_re($item, $valid_item_values)

  $filename_real = "${::pam::limits::conf_d_real}/${priority}_${name}.conf"
  $content_real = "# MANAGED BY PUPPET\n${domain} ${type} ${item} ${value}\n"

  if $source != '' {
    File["pam_limits_${priority}_${name}"] {
      source  => $source
    }
  } else {
    File["pam_limits_${priority}_${name}"] {
      content => $content_real
    }
  }

  @file { "pam_limits_${priority}_${name}":
    ensure => $ensure,
    path   => $filename_real,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    tag    => 'pam_limits_conf_d'
  }

}
