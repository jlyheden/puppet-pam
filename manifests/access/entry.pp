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
  $origins      = 'ALL'
) {

  include pam::params

  # Parameter validation and string building
  $valid_ensure_values = [ 'present', 'absent' ]
  validate_re($ensure, $valid_ensure_values)

  # Initially threw fail as default selector but apparently
  # not possible as per issue #4598
  case $permission {
    allow: { $permission_real = '+' }
    deny: { $permission_real = '-' }
    default: {
      fail("Unsupported permission ${permission}. Valid values are: allow, deny")
    }
  }
  case $object_type {
    user: {
      $name_real = "20_pam_access_conf_${object_type}_${object}"
      $content_real = "${permission_real}:${object}:${origins}\n"
    }
    group: {
      $name_real = "20_pam_access_conf_${object_type}_${object}"
      $content_real = "${permission_real}:(${object}):${origins}\n"
    }
    default: { fail("Unsupported object_type ${object_type}. Valid values are: user, group") }
  }

  # Virtual resource, pam::access will realize it
  # unless access.conf file is managed entirely
  # by template file or source file
  @concat::fragment { $name_real:
    ensure  => $ensure,
    target  => $pam::access::accessfile_real,
    content => $content_real,
    order   => '20',
    tag     => 'pam_access'
  }

}
