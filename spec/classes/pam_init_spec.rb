require 'spec_helper'

describe 'pam' do

  context 'ubuntu lucid defaults' do
    let (:facts) { {
      :lsbdistcodename  => 'lucid',
      :operatingsystem  => 'Ubuntu',
    } }
    it do should contain_package('pam').with(
      'ensure'  => 'present',
      'name'    => [ 'libpam0g', 'libpam-modules', 'libpam-runtime' ]
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
    it do should contain_package('pam').with(
      'ensure'  => 'latest',
      'name'    => [ 'libpam0g', 'libpam-modules', 'libpam-runtime' ]
    ) end
  end

end
