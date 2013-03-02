require 'spec_helper'

describe 'pam::ldap' do

  context 'ubuntu lucid defaults' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'present',
      'name'    => 'libpam-ldapd'
    ) end
  end

  context 'ubuntu lucid autoupgrade' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'latest',
      'name'    => 'libpam-ldapd'
    ) end
  end

  context 'ubuntu lucid decomission' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :ensure       => 'absent',
      :autoupgrade  => true
    } }
    it do should contain_package('pamldap').with(
      'ensure'  => 'absent',
      'name'    => 'libpam-ldapd'
    ) end
  end

end
