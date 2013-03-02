require 'spec_helper'

describe 'pam::access::entry' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu',
    :concat_basedir   => '/var/lib/puppet/concat'
  } } 

  let (:pre_condition) do [
    'class { "pam": }',
    'class { "pam::access": }'
  ]
  end

  context 'with object => Domain Users, object_type => group, permission => allow' do
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

  context 'with object => bogus, object_type => user, permission => allow' do
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

  context 'with object => bogus, object_type => fail, permission => allow' do
    let (:name) { 'allow_bogus_user' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'bogus',
      :object_type  => 'fail',
      :permission   => 'allow'
    } }
    it do
      expect {
        should include_class('pam::access')
      }.to raise_error(Puppet::Error, /Unsupported object_type fail. Valid values are: user, group/)
    end
  end

  context 'with object => bogus, object_type => user, permission => maybe_allow' do
    let (:name) { 'allow_bogus_user' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'bogus',
      :object_type  => 'user',
      :permission   => 'maybe_allow'
    } }
    it do
      expect {
        should include_class('pam::access')
      }.to raise_error(Puppet::Error, /Unsupported permission maybe_allow. Valid values are: allow, deny/)
    end
  end

end
