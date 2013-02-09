define pam::access::entry ( $object,
                            $ensure = 'present',
                            $object_type = 'user',
                            $permission = 'allow',
                            $origins = 'ALL' ) {

  include pam::params

  # Parameter validation and string building
  $permission_real = $permission ? {
    'allow' => '+',
    'deny'  => '-',
    default => fail("Unsupported permission ${permission}. Valid values are: allow, deny")
  }
  $name_real = $object_type ? {
    'user'  => "20_pam_access_conf_user_${object}",
    'group' => "20_pam_access_conf_group_${object}",
    default => fail("Unsupported object_type ${object_type}. Valid values are: user, group")
  }
  $content_real = $object_type ? {
    'user'  => "${permission_real} : ${object} : ${origins}\n",
    'group' => "${permission_real} : (${object}) : ${origins}\n",
    default => fail("Unsupported object_type ${object_type}. Valid values are: user, group")
  }

  @concat::fragment { $name_real:
    target  => $pam::access::accessfile,
    content => $content_real,
    order   => '20',
    tag     => 'pam_access'
  }

}
