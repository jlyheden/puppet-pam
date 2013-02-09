class pam::mkhomedir (  $ensure = 'present',
                        $umask = $pam::params::umask,
                        $skel = $pam::params::skel ) inherits pam::params {

  include pam

  validate_re($ensure, [ 'present', 'absent' ])

  file { 'pam_auth_update_mkhomedir_file':
    ensure  => $ensure,
    path    => $pam::params::pam_auth_update_mkhomedir_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($pam::params::pam_auth_update_mkhomedir_tmpl),
    notify  => Exec['pam_auth_update']
  }

}
