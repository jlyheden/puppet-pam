require 'spec_helper'

describe 'pam' do

  # set depending facts
  let (:facts) { {
    :operatingsystem  => 'Ubuntu'
  } }

  context 'with default params' do
    it do should contain_package('pam').with(
      'ensure'  => 'present',
      'name'    => 'libpam-runtime'
    ) end
  end

  context 'with autoupgrade => true' do
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('pam').with(
      'ensure'  => 'latest',
      'name'    => 'libpam-runtime'
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
