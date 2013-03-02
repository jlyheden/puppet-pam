require 'spec_helper'

describe 'pam::access' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  let (:pre_condition) do [
    'class {"pam": }',
  ]
  end

  context 'with default params' do
    it do should contain_file('pam_auth_update_access_file').with(
      'ensure'  => 'present',
      'path'    => '/usr/share/pam-configs/access',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[pam_auth_update]'
    ) end
    it do
      should contain_file('pam_auth_update_access_file').with_content(/.*\n\trequired                        pam_access.so accessfile=\/etc\/security\/access.conf\n$/)
    end
    it do should contain_concat('/etc/security/access.conf').with(
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644'
    ) end
    it do
      should contain_concat__fragment('10_pam_access_conf_head').with_content(/^# MANAGED BY PUPPET\n/)
    end
    it do
      should contain_concat__fragment('90_pam_access_conf_foot').with_content(/-:ALL EXCEPT root:ALL\n/)
    end
  end

  context "with fieldsep => ',' debug => true accessfile => /custom/accessfile" do
    let (:params) { {
      :fieldsep   => ',',
      :debug      => true,
      :accessfile => '/custom/accessfile'
    } }
    it do should contain_file('pam_auth_update_access_file').with(
      'ensure'  => 'present',
      'path'    => '/usr/share/pam-configs/access',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[pam_auth_update]'
    ) end
    it do
      should contain_file('pam_auth_update_access_file').with_content(/.*\n\trequired                        pam_access.so accessfile=\/custom\/accessfile debug fieldsep=','\n$/)
    end
    it do
      should contain_concat__fragment('90_pam_access_conf_foot').with_content(/-:ALL EXCEPT root:ALL\n/)
    end
  end

  context "with source => puppet:///modules/pam/test/accessfile template => ''" do
    let (:params) { {
      :source   => 'puppet:///modules/pam/test/accessfile',
      :template => ''
    } }
    it do should contain_file('accessfile').with(
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'source'  => 'puppet:///modules/pam/test/accessfile'
    ) end
  end

  context 'with invalid operatingsystem' do
    let (:facts) { {
      :operatingsystem => 'beos'
    } }
    it do
      expect {
        should contain_class('pam::params')
      }.to raise_error(Puppet::Error, /Unsupported operatingsystem beos/)
    end
  end

end
