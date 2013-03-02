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
      should contain_concat__fragment('20_pam_access_conf_allow_group_Domain Users').with_content(/\+:\(Domain Users\):ALL\n/)
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
      should contain_concat__fragment('20_pam_access_conf_allow_user_bogus').with_content(/\+:bogus:ALL\n/)
    end
  end 

  context 'with object => ALL, object_type => ALL, permission => deny, except_user => myuser' do
    let (:name) { 'block_all_except_myuser' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'ALL',
      :object_type  => 'ALL',
      :permission   => 'deny',
      :except_user  => 'myuser',
      :priority     => '90',
    } }
    it do
      should contain_concat__fragment('90_pam_access_conf_deny_ALL_ALL_except_myuser').with_content(/\-:ALL EXCEPT myuser:ALL\n/)
    end
  end

  context 'with object => ALL, object_type => ALL, permission => deny, except_user => myuser, with listsep => , in pam::access' do
    let (:name) { 'block_all_except_myuser' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'ALL',
      :object_type  => 'ALL',
      :permission   => 'deny',
      :except_user  => 'myuser',
      :priority     => '90',
    } }
    let (:pre_condition) do [
      'class { "pam": }',
      'class { "pam::access": listsep => "," }'
    ]
    end
    it do
      should contain_concat__fragment('90_pam_access_conf_deny_ALL_ALL_except_myuser').with_content(/\-:ALL,EXCEPT,myuser:ALL\n/)
    end
  end

  context 'with object => ALL, object_type => ALL, permission => deny, except_user => myuser, except_group => [ group1, group2 ]' do
    let (:name) { 'block_all_except_myuser' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'ALL',
      :object_type  => 'ALL',
      :permission   => 'deny',
      :except_user  => 'myuser',
      :except_group => [ 'group1', 'group2'],
      :priority     => '90',
    } }
    it do
      should contain_concat__fragment('90_pam_access_conf_deny_ALL_ALL_except_(group1) (group2) myuser').with_content(/\-:ALL EXCEPT \(group1\) \(group2\) myuser:ALL\n/)
    end
  end

  context 'with object => ALL, object_type => ALL, permission => deny, except_user => [ user1, user2 ], except_group => group1 with listsep => , in pam::access' do
    let (:name) { 'block_all_except_myuser' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'ALL',
      :object_type  => 'ALL',
      :permission   => 'deny',
      :except_user  => [ 'user1', 'user2' ],
      :except_group => 'group1',
      :priority     => '90',
    } }
    let (:pre_condition) do [
      'class { "pam": }',
      'class { "pam::access": listsep => "," }'
    ]
    end
    it do
      should contain_concat__fragment('90_pam_access_conf_deny_ALL_ALL_except_(group1),user1,user2').with_content(/\-:ALL,EXCEPT,\(group1\),user1,user2:ALL\n/)
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
      }.to raise_error(Puppet::Error, /"fail" does not match/)
    end
  end

  context 'with object => bogus, object_type => user, permission => fail' do
    let (:name) { 'allow_bogus_user' }
    let (:title) { 'allow_bogus_user' }
    let (:params) { {
      :object       => 'bogus',
      :object_type  => 'user',
      :permission   => 'fail'
    } }
    it do
      expect {
        should include_class('pam::access')
      }.to raise_error(Puppet::Error, /"fail" does not match/)
    end
  end

end
