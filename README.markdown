# Module: pam

This is the Puppet module for managing PAM - Pluggable Authentication Module.

## Dependencies

* puppet-concat: https://github.com/ripienaar/puppet-concat
* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

## Usage

In it's simplest form, which essentially just make sure that PAM packages
are installed (which they always are)

    :::python
        include pam

### Usage: PAM LDAP

Some sub namespaced classes exists for more specific purposes.

The following installs pam-ldap and configures pam to query LDAP for user logins:
	:::puppet
		include pam::ldap

To enable automatic creation of user home directories:
	:::puppet
		include pam::mkhomedir
		# or
		class { 'pam::mkhomedir':
		  ensure => present,
		  umask  => '0022',
		  skel   => '/etc/skel'
		}

To control server access via the PAM access module:
<pre>
include pam::access
# or
class { 'pam::access':
  ensure     => present,
  accessfile => '/etc/security/access.conf',
  debug      => true,
  listsep    => ',',
}
</pre>

To manage individual access entries in access.conf:
<pre>
pam::access::entry { 'allow_domain_users_group':
  ensure      => present,
  object      => 'Domain Users',
  object_type => 'group',
  permission  => 'allow',
  origins     => 'ALL',
}
</pre>
