# == Class: template::params
#
# This class is only used to set variables
#
class template::params {

  $ensure = present
  $service_enable = true
  $service_status = running
  $autoupgrade = false
  $autorestart = true
  $source = undef
  $template = 'template/template.conf.erb'
  $source_dir = undef
  $source_dir_purge = undef
  
  # This mandates which distributions are supported
  # To add support for other distributions simply add
  # a matching regex line to the operatingsystem fact
  case $::lsbdistcodename {
    lucid: {
      $package = 'template'
      $service = 'template'
      $config_file = '/etc/template.conf'
    }
    default: {
      fail("Unsupported operatingsystem ${::operatingsystem}")
    }
  }

}