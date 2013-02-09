class pam::access ( $ensure = 'present',
                    $accessfile = $pam::params::accessfile,
                    $debug = $pam::params::debug,
                    $noaudit = $pam::params::noaudit,
                    $fieldsep = $pam::params::fieldsep,
                    $listsep = $pam::params::listsep,
                    $nodefgroup = $pam::params::nodefgroup ) inherits pam::params {

  include pam

  $accessfile_entry = $accessfile ? {
    undef   => '',
    ''      => '',
    default => " accessfile='${accessfile}'"
  }
  $debug_entry = $debug ? {
    true    => ' debug',
    false   => '',
    default => fail("Unsupported debug value ${debug}")
  }
  $noaudit_entry = $noaudit ? {
    true    => ' noaudit',
    false   => '',
    default => fail("Unsupported noaudit value ${noaudit}")
  }
  $fieldsep_entry = $fieldsep ? {
    undef   => '',
    ''      => '',
    default => " fieldsep='${fieldsep}'"
  }
  $listsep_entry = $listsep ? {
    undef   => '',
    ''      => '',
    default => " listsep='${listsep}"
  }
  $nodefgroup_entry = $nodefgroup ? {
    true    => ' nodefgroup',
    false   => '',
    default => fail("Unsupported nodefgroup value ${nodefgroup}")
  }

  $pam_access_parameters = "${accessfile_entry}${debug_entry}${noaudit_entry}${fieldsep_entry}${listsep_entry}${nodefgroup_entry}"

  file { 'pam_auth_update_access_file':
    ensure  => $ensure,
    path    =>$pam::params::pam_auth_update_access_file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($pam::params::pam_auth_update_access_tmpl),
    notify  => Exec['pam_auth_update']
  }

}
