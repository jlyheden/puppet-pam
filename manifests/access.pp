class pam::access ( $ensure = 'present',
                    $accessfile = $pam::params::accessfile,
                    $debug = $pam::params::debug,
                    $noaudit = $pam::params::noaudit,
                    $fieldsep = $pam::params::fieldsep,
                    $listsep = $pam::params::listsep,
                    $nodefgroup = $pam::params::nodefgroup,
                    $source = $pam::params::access_source,
                    $template = $pam::params::access_template ) inherits pam::params {

  include pam

  # Input validation
  validate_re($ensure, [ 'present', 'absent' ])

  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }
  $manage_file_content = $template ? {
    ''        => undef,
    default   => template($template),
  }

  # Sanitized string builder variables
  # for pam_access.so options
  $accessfile_entry = $accessfile ? {
    undef   => '',
    ''      => '',
    default => " accessfile=${accessfile}"
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

  # Ubuntu uses pam-auth-update to build pam configuration
  case $::lsbdistcodename {
    lucid: {
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
    default: {
      fail("Unsupported distribution ${::lsbdistcodename}")
    }
  }

  case $ensure {
    present: {

      # use fragments if file source not provided
      if $manage_file_source == undef and $manage_file_template == undef {
        concat { $accessfile:
          owner   => 'root',
          group   => 'root',
          mode    => '0644'
        }
        concat::fragment { '10_pam_access_conf_head':
          target  => $accessfile,
          content => "# MANAGED BY PUPPET\n",
          order   => '10'
        }
        concat::fragment { '90_pam_access_conf_foot':
          target  => $accessfile,
          content => "-:ALL EXCEPT root: ALL\n",
          order   => '90'
        }
        Concat::Fragment <| tag == 'pam_access' |>
      # otherwise manage file as usual
      } else {
        file { $accessfile:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $manage_file_template,
          source  => $manage_file_source
        }
      }

    }
    default: {} # leave files as is in any other case
  }

}
