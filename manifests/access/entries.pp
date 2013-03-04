# == Class: pam::access::entries
#
# This class is a class wrapper around pam::access::entry
# It makes it easier to standardize input format when build
# resources from hiera, as data can be declared using a
# centrally managed entry point and without explicitly
# calling hiera_hash() in site modules.
#
# === Parameters
#
# [*parameters*]
#   PAM access entries formated as a hash (pam::access::entry)
#   Valid values: see pam::access::entry
#
# === Sample Usage
#
# * Does nothing
#   class { 'pam::access::entries': }
#
# * Adds access to Domain Admins group
#   class { 'pam::access::entries':
#     parameters => {
#       'allow_domain_users_group' => {
#         ensure      => present,
#         object      => 'Domain Admins',
#         object_type => 'group',
#         permission  => 'allow',
#         origins     => 'ALL',
#       }
#     }
#   }
#
# * Within matching hiera yaml file you could add:
# pam::access::entries:
#   'allow_domain_users_group':
#     ensure: present
#     object: 'Domain Admins'
#     object_type: 'group'
#     permission: 'allow'
#     origins: 'ALL'
#
class pam::access::entries ( $parameters = {} ) {

  include pam
  include pam::params

  create_resources('pam::access::entry',$parameters)

}
