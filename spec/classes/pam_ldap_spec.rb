require 'spec_helper'

describe 'pam::ldap' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat',
    :nss_local_users  => 'user1,user2,user3'
  } } 

  context 'with default params' do
    it do should contain_package('pamldap').with(
      'ensure'  => 'present',
      'name'    => 'libpam-ldap'
    ) end
    it do should contain_file('pam_auth_update_ldap_file').with(
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'source'  => 'puppet:///modules/pam/pam-configs/ldap',
      'notify'  => 'Exec[pam_auth_update]',
      'require' => 'Package[pamldap]'
    ) end
    it do should contain_file('ldap.conf').with(
      'ensure'  => 'present',
      'path'    => '/etc/ldap.conf',
      'source'  => nil
    ).with_content("# MANAGED BY PUPPET - don't edit by hand

base dc=example,dc=net
uri ldapi:///
ldap_version 3
rootbinddn cn=manager,dc=example,dc=net
pam_password md5
nss_initgroups_ignoreusers user1,user2,user3
") end
  end

  context 'with autoupgrade => true' do
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'latest',
      'name'    => 'libpam-ldap'
    ) end
  end

  context 'with ensure => absent, autoupgrade => true' do
    let (:params) { {
      :ensure       => 'absent',
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'absent',
      'name'    => 'libpam-ldap'
    ) end
  end

  context 'with ldapconf_source => puppet:///modules/pam/somefile' do
    let (:params) { {
      :ldapconf_source  => 'puppet:///modules/pam/somefile'
    } }
    it do should contain_file('ldap.conf').with(
      'content' => nil,
      'source'  => 'puppet:///modules/pam/somefile'
    ) end
  end

  context 'with ldapconf_params => [ value1, value2, value3 ]' do
    let (:params) { {
      :ldapconf_params => [ 'value1', 'value2', 'value3' ]
    } }
    it do should contain_file('ldap.conf').with(
      'source'  => nil
    ).with_content("# MANAGED BY PUPPET - don't edit by hand

value1
value2
value3
nss_initgroups_ignoreusers user1,user2,user3
") end
  end

  context 'with ldapconf_params => [ value1, nss_initgroups_ignoreusers blah ]' do
    let (:params) { {
      :ldapconf_params => [ 'value1', 'nss_initgroups_ignoreusers blah' ]
    } }
    it do should contain_file('ldap.conf').with(
      'source'  => nil
    ).with_content("# MANAGED BY PUPPET - don't edit by hand

value1
nss_initgroups_ignoreusers blah
") end
  end

  context 'with ldapconf_content => content ]' do
    let (:params) { {
      :ldapconf_content => 'content'
    } }
    it do should contain_file('ldap.conf').with(
      'source'  => nil
    ).with_content("content") end
  end

  context 'with invalid operatingsystem' do
    let (:facts) { {
      :operatingsystem => 'beos'
    } }
    let (:params) { {
      :autoupgrade  => true
    } }
    it do
      expect {
        should contain_class('pam::params')
      }.to raise_error(Puppet::Error, /Unsupported operatingsystem beos/)
    end
  end

end
