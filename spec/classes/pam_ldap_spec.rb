require 'spec_helper'

describe 'pam::ldap' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  context 'with default params' do
    it do should contain_package('pamldap').with(
      'ensure'  => 'present',
      'name'    => 'libpam-ldapd'
    ) end
  end

  context 'with autoupgrade => true' do
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'latest',
      'name'    => 'libpam-ldapd'
    ) end
  end

  context 'with ensure => absent, autoupgrade => true' do
    let (:params) { {
      :ensure       => 'absent',
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
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
