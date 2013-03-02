# == Define: pam::access:entry
#
# Manages an entry in pam_access.so access.conf file
# Allows granting access or blocking access based
# on certain criterias
#
# === Parameters
#
# [*object*]
#   Name of object to manage access to
#   Valid values: <tt>username</tt>, <tt>groupname</tt>, <tt>ALL</tt>
#
# [*ensure*]
#   Controls the resource definition
#   Valid values: <tt>present</tt>, <tt>absent</tt>
#
# [*object_type*]
#   Specifies user or group entry
#   Valid values: <tt>user</tt>, <tt>group</tt>
#
# [*permission*]
#   Specifies if entry should be allowed or denied
#   Valid values: <tt>allow</tt>, <tt>deny</tt>
#
# [*origins*]
#   A list of one or more tty names (for non-networked logins),
#   host names, domain names (begin with "."),
#   host addresses, internet network numbers (end with "."),
#   internet network addresses with network mask (where network mask
#   can be a decimal number or an internet address also),
#   ALL (which always matches) or LOCAL.
#   Valid values: see above
#
# [*priority*]
#   Determines where in access.conf this entry should
#   be evaluated. Lower number means higher up in the
#   configuration file.
#   Valid values: numerical value
#
# [*except_user*]
#   Adds user except to the access rule.
#   Most useful when blocking access to a large
#   matching pattern but want to add certain
#   excluding entries.
#   Valid values: string or array of usernames
#
# [*except_group*]
#   Adds group except to the access rule.
#   Most useful when blocking access to a large
#   matching pattern but want to add certain
#   excluding entries.
#   Valid values: string or array of groupnames
#
# === Sample usage
#
# pam::access::entry { 'allow_domain_users_group':
#   ensure      => present,
#   object      => 'Domain Users',
#   object_type => 'group',
#   permission  => 'allow',
#   origins     => 'ALL',
# }
#
define pam::access::entry (
  $object,
  $ensure       = 'present',
  $object_type  = 'user',
  $permission   = 'allow',
  $origins      = 'ALL',
  $priority     = '20',
  $except_user  = '',
  $except_group = ''
) {

  include pam::params

  # Parameter validation
  $valid_ensure_values = [ 'present', 'absent' ]
  $valid_permission_values = [ 'allow', 'deny' ]
  $valid_object_type_values = [ 'user', 'group', '^(?i:all)$' ]
  validate_re($ensure, $valid_ensure_values)
  validate_re($priority, '^[0-9]+$')
  validate_re($permission, $valid_permission_values)
  validate_re($object_type, $valid_object_type_values)

  # ACL builder
  $except_list_real = chomp(template('pam/ruby_except_breakout.erb'))
  $permission_real = $permission ? {
    allow => '+',
    deny  => '-'
  }
  $object_name_real = $object_type ? {
    'user'        => $object,
    'group'       => "(${object})",
    /^(?i:all)$/  => 'ALL'
  }
  $name_real = $except_list_real ? {
    ''      => "${priority}_pam_access_conf_${permission}_${object_type}_${object}",
    default => "${priority}_pam_access_conf_${permission}_${object_type}_${object}_except_${except_list_real}"
  }
  $content_real = $except_list_real ? {
    ''      => "${permission_real}:${object_name_real}:${origins}\n",
    default => "${permission_real}:${object_name_real}${::pam::access::listsep_entry_real}EXCEPT${::pam::access::listsep_entry_real}${except_list_real}:${origins}\n"
  }

  # Virtual resource, pam::access will realize it
  # unless access.conf file is managed entirely
  # by template file or source file
  @concat::fragment { $name_real:
    ensure  => $ensure,
    target  => $pam::access::accessfile_real,
    content => $content_real,
    order   => $priority,
    tag     => 'pam_access'
  }

}
