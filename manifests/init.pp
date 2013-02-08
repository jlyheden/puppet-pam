# == Class: template
#
# This module manages the template server. More descriptions here
#
# === Parameters
#
# [*ensure*]
#   Controls the software installation
#   Valid values: <tt>present</tt>, <tt>absent</tt>, <tt>purge</tt>
#
# [*service_enable*]
#   Controls if service should be enabled on boot
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*service_status*]
#   Controls service state.
#   Valid values: <tt>running</tt>, <tt>stopped</tt>, <tt>unmanaged</tt>
#
# [*autoupgrade*]
#   If Puppet should upgrade the software automatically
#   Valid values: <tt>true</tt>, <tt>false</tt>
#
# [*autorestart*]
#   If Puppet should restart service on config changes
#   Valid values: <tt>true</tt>, <tt>false</tt>
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
#   Hash variable to pass to template
#   Valid values: hash, ex:  <tt>{ 'option' => 'value' }</tt>
#
# === Sample Usage
#
# * Installing with default settings
#   class { 'template': }
#
# * Uninstalling the software
#   class { 'template': ensure => absent }
#
# * Installing, with service disabled on boot and using custom passwd settings
#   class { 'template:
#     service_enable    => false,
#     parameters_passwd => {
#       'enable-cache'  => 'no'
#     }
#   }
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
# Firstname Lastname <firstname.lastname@artificial-solutions.com>
#
class template (  $ensure = $template::params::ensure,
                  $service_enable = $template::params::service_enable,
                  $service_status = $template::params::service_status,
                  $autoupgrade = $template::params::autoupgrade,
                  $autorestart = $template::params::autorestart,
                  $source = $template::params::source,
                  $template = $template::params::template,
                  $parameters = {} ) inherits template::params {

  # Input validation
  validate_re($ensure,[ 'present', 'absent', 'purge' ])
  validate_re($service_status, [ 'running', 'stopped', 'unmanaged' ])
  validate_bool($autoupgrade)
  validate_bool($autorestart)
  validate_hash($parameters)

  # 'unmanaged' is an unknown service state
  $service_status_real = $service_status ? {
    'unmanaged' => undef,
    default     => $service_status
  }

  # Manages automatic upgrade behavior
  if $ensure == 'present' and $autoupgrade == true {
    $ensure_package = 'latest'
  } else {
    $ensure_package = $ensure
  }

  case $ensure {

    # If software should be installed
    present: {
      if $autoupgrade == true {
        Package['template'] { ensure => latest }
      } else {
        Package['template'] { ensure => present }
      }
      if $autorestart == true {
        Service['template/service'] { subscribe => File['template/config'] }
      }
      if $source == undef {
        File['template/config'] { content => template($template) }
      } else {
        File['template/config'] { source => $source }
      }
      File {
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Package['template'],
        before  => Service['template/service']
      }
      service { 'template/service':
        ensure  => $service_status_real,
        name    => $template::params::service,
        enable  => $service_enable,
        require => [ Package['template'], File['template/config' ] ]
      }
      file { 'template/config':
        ensure  => present,
        path    => $template::params::config_file,
      }
    }
    
    # If software should be uninstalled
    absent,purge: {
      Package['template'] { ensure => $ensure }
    }
    
    # Catch all, should not end up here due to input validation
    default: {
      fail("Unsupported ensure value ${ensure}")
    }
  }
  
  package { 'template':
    name    => $template::params::package
  }

}