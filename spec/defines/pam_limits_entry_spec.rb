require 'spec_helper'

describe 'pam::limits::entry' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  let (:pre_condition) do [
    'class { "pam": }',
    'class { "pam::limits": }'
  ]
  end

  context 'with domain => myuser, type => soft, item => core, value => 1000, priority => 10' do
    let (:name) { 'myuser_soft_core_limit' }
    let (:title) { 'myuser_soft_core_limit' }
    let (:params) { {
      :domain   => 'myuser',
      :type     => 'soft',
      :item     => 'core',
      :value    => '1000',
      :priority => '10'
    } } 
    it do
      should contain_file('pam_limits_10_myuser_soft_core_limit').with(
        'ensure'  => 'present',
        'path'    => '/etc/security/limits.d/10_myuser_soft_core_limit.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644'
      )
    end
    it do
      should contain_file('pam_limits_10_myuser_soft_core_limit').with_content(/myuser soft core 1000\n/)
    end
  end

end
