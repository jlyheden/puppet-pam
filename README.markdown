# Module: pam

This is the Puppet module for managing PAM - Pluggable Authentication Module.

## Dependencies

* puppet-concat: https://github.com/ripienaar/puppet-concat
* puppet-stdlib: https://github.com/puppetlabs/puppetlabs-stdlib

## Usage: pam

In it's simplest form, which essentially just make sure that PAM packages
are installed (which they always are)

> include pam

### Usage: pam ldap

Some sub namespaced classes exists for more specific purposes.

The following installs pam-ldap and configures pam to query LDAP for user logins:
	
> include pam::ldap

### Usage: pam mkhomedir

To enable automatic creation of user home directories:

> include pam::mkhomedir
> # or
> class { 'pam::mkhomedir':
>  ensure => present,
>  umask  => '0022',
>  skel   => '/etc/skel'
> }

### Usage: pam access

To control server access via the PAM access module:

> include pam::access
> # or
> class { 'pam::access':
>   ensure     => present,
>   accessfile => '/etc/security/access.conf',
>   debug      => true,
>   listsep    => ',',
> }

To manage individual access entries in access.conf:

> pam::access::entry { 'allow_domain_users_group':
>   ensure      => present,
>   object      => 'Domain Users',
>   object_type => 'group',
>   permission  => 'allow',
>   origins     => 'ALL',
> }

