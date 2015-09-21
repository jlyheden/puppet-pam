# Module: pam
[![Build Status](https://travis-ci.org/jlyheden/puppet-pam.png)](https://travis-ci.org/jlyheden/puppet-pam)

This is the Puppet module for managing PAM - Pluggable Authentication Module.

## Dependencies

* puppet-concat: https://github.com/puppetlabs/puppet-concat
* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

### Usage: pam

The base pam module is not particularly useful, it ensures that the
base pam packages are installed - which they are by default anyway.

	include pam


### Usage: pam ldap

To install the ldap pam packages and enable them in the system pam
configuration section:
	
	include pam::ldap


### Usage: pam mkhomedir

To enable automatic creation of user home directories:

	include pam::mkhomedir

Custom settings can be provided for umask and skeleton directory:

	class { 'pam::mkhomedir':
		ensure => present,
		umask  => '0022',
		skel   => '/etc/skel'
	}


### Usage: pam access

To control server access via the PAM access module:

	include pam::access

Custom settings can be applied, like delimiter character (which
is useful when handling groups with whitespaces - Domain Admins
for example), and other settings. See access.pp for details:

	class { 'pam::access':
		ensure     => present,
		accessfile => '/etc/security/access.conf',
		debug      => true,
		listsep    => ',',
	}

To manage individual access entries in access.conf:

	pam::access::entry { 'allow_domain_users_group':
		ensure      => present,
		object      => 'Domain Users',
		object_type => 'group',
		permission  => 'allow',
		origins     => 'ALL',
	}

