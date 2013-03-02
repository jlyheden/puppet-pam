require 'spec_helper'

describe 'pam::limits' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  context 'with default params' do
    it do should contain_file('pam_auth_update_limits_file').with(
      'ensure'  => 'present',
      'path'    => '/usr/share/pam-configs/limits',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[pam_auth_update]'
    ) end
    it do
      should contain_file('pam_auth_update_limits_file').with_content(/.*\n\trequired                        pam_limits.so conf=\/etc\/security\/limits.conf\n$/)
    end
    it do
      should contain_file('pam_limits_conf_d').with(
        'ensure'  => 'directory',
        'path'    => '/etc/security/limits.d',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'purge'   => true,
        'force'   => true,
        'recurse' => true
      )
    end
    it do
      should contain_file('pam_limits_conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/security/limits.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'source'  => 'puppet:///modules/pam/limits.conf'
      )
    end
  end

  context 'with debug => true, noaudit => true' do
    let (:params) { {
      :debug    => true,
      :noaudit  => true
    } }
    it do
      should contain_file('pam_auth_update_limits_file').with_content(/.*\n\trequired                        pam_limits.so conf=\/etc\/security\/limits.conf debug noaudit\n$/)
    end
  end

  context 'with ensure => absent' do
    let (:params) { {
      :ensure => 'absent'
    } }
    it do should contain_file('pam_auth_update_limits_file').with(
      'ensure'  => 'absent',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644'
    ) end
  end

  context 'with purge_conf_d => false' do
    let (:params) { {
      :purge_conf_d => false
    } }
    it do
      should contain_file('pam_limits_conf_d').with(
        'ensure'  => 'directory',
        'purge'   => nil,
        'force'   => nil,
        'recurse' => nil
      )
    end
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
