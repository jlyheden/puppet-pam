require 'spec_helper'

describe 'pam::ldapd' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :lsbdistcodename  => 'lucid',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  context 'with default params' do
    it do should contain_package('pamldapd').with(
      'ensure'  => 'present',
      'name'    => 'libpam-ldapd'
    ) end
    it do should contain_file('pam_auth_update_ldap_file').with(
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'source'  => ['puppet:///modules/pam/pam-configs/lucid_ldap', 'puppet:///modules/pam/pam-configs/ldap'],
      'notify'  => 'Exec[pam_auth_update]',
      'require' => 'Package[pamldapd]'
    ) end
  end

  context 'with autoupgrade => true' do
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('pamldapd').with(
      'ensure'  => 'latest',
      'name'    => 'libpam-ldapd'
    ) end
  end

  context 'with ensure => absent, autoupgrade => true' do
    let (:params) { {
      :ensure       => 'absent',
      :autoupgrade  => true
    } }
    it do should contain_package('pamldapd').with(
      'ensure'  => 'absent',
      'name'    => 'libpam-ldapd'
    ) end
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
