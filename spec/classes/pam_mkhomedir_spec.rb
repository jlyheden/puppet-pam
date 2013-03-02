require 'spec_helper'

describe 'pam::mkhomedir' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  context 'with default params' do
    it do should contain_file('pam_auth_update_mkhomedir_file').with(
      'ensure'  => 'present',
      'path'    => '/usr/share/pam-configs/mkhomedir',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[pam_auth_update]'
    ) end
    it do
      should contain_file('pam_auth_update_mkhomedir_file').with_content(/.*\n\trequired                        pam_mkhomedir.so skel=\/etc\/skel umask=0022\n$/)
    end
  end

  context 'with umask => 0002, skel => /custom/skel' do
    let (:params) { {
      :umask  => '0002',
      :skel   => '/custom/skel'
    } }
    it do should contain_file('pam_auth_update_mkhomedir_file').with(
      'ensure'  => 'present',
      'path'    => '/usr/share/pam-configs/mkhomedir',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[pam_auth_update]'
    ) end
    it do
      should contain_file('pam_auth_update_mkhomedir_file').with_content(/.*\n\trequired                        pam_mkhomedir.so skel=\/custom\/skel umask=0002\n$/)
    end
  end

  context 'with ensure => absent' do
    let (:params) { {
      :ensure => 'absent'
    } }
    it do should contain_file('pam_auth_update_mkhomedir_file').with(
      'ensure'  => 'absent',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644'
    ) end
  end

  context 'with umask => 9500' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    let (:params) { {
      :umask  => '9500',
    } }
    it do
      expect {
        should contain_file('pam_auth_update_mkhomedir_file')
      }.to raise_error(Puppet::Error, /\"9500\" does not match/)
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
