require 'spec_helper'

describe 'pam::access::entry' do

  let (:facts) { {
    :lsbdistcodename  => 'lucid',
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } }
  let (:pre_condition) do [
    'class { "pam": }',
    'class { "pam::access": }'
  ]
  end

  context 'add access to Domain Users group' do
    let (:name) { 'allow_domain_users_group' }
    let (:title) { 'allow_domain_users_group' }
    let (:params) { {
      :object       => 'Domain Users',
      :object_type  => 'group',
      :permission   => 'allow'
    } } 
    it do
      should contain_concat__fragment('20_pam_access_conf_group_Domain Users').with_content(/\+:\(Domain Users\):ALL\n/)
    end
  end

  context 'add access to bogus user' do
    let (:name) { 'allow_bogus_user' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'bogus',
      :object_type  => 'user',
      :permission   => 'allow'
    } } 
    it do
      should contain_concat__fragment('20_pam_access_conf_user_bogus').with_content(/\+:bogus:ALL\n/)
    end
  end 

end
