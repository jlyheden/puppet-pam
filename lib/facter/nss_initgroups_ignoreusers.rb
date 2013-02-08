# Fact distributed with puppet-pam module
Facter.add('nss_initgroups_ignoreusers') do
  confine :kernel => 'Linux'
  setcode do
    ignore_users = `cut -f 1 -d':' /etc/passwd || echo `
    if ignore_users.length > 0
      ignore_users.chomp.gsub(/\n/,',')
    else
      ignore_users
    end
  end
end
