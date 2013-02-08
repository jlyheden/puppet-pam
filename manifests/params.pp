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

  # ldap
  $ldap_template = 'pam/ldap.conf.erb'

  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the operatingsystem fact
  case $::lsbdistcodename {
    lucid: {
      # base
      $package = [ 'libpam0g', 'libpam-modules', 'libpam-runtime' ]
      # ldap 
      $ldap_package = 'libpam-ldap'
      $ldap_config_file = '/etc/ldap.conf'
    }
    default: {
      fail("Unsupported distribution ${::lsbdistcodename}")
    }
  }

}
