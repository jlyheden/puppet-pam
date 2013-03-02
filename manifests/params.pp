# == Class: pam::params
#
# This class is only used to set variables
#
class pam::params {

  # base
  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = undef
  $source_dir = undef
  $source_dir_purge = undef

  # pam mkhomedir
  $umask = '0022'
  $skel = '/etc/skel'

  # pam access
  $access_template = ''
  $access_source = ''
  $accessfile = '/etc/security/access.conf'
  $debug = false
  $noaudit = false
  $fieldsep = undef
  $listsep = undef
  $nodefgroup = false
  $access_restrictive = false   # if block all users except root should be added by default in pam::access

  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the operatingsystem fact
  case $::operatingsystem {
    'Ubuntu','Debian': {
      # base
      $package = [ 'libpam0g', 'libpam-modules', 'libpam-runtime' ]
      # ldap
      $ldap_package = 'libpam-ldapd'
      $pam_auth_update_mkhomedir_tmpl = 'pam/pam_auth_update/mkhomedir.erb'
      $pam_auth_update_access_tmpl = 'pam/pam_auth_update/access.erb'
      $pam_auth_update_dir = '/usr/share/pam-configs'
      $pam_auth_update_mkhomedir_file = "${pam_auth_update_dir}/mkhomedir"
      $pam_auth_update_access_file = "${pam_auth_update_dir}/access"
    }
    default: {
      fail("Unsupported operatingsystem ${::operatingsystem}")
    }
  }

}
