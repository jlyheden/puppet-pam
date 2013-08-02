# nss_local_users.rb

Facter.add(:nss_local_users) do
  confine :kernel => "Linux"
  setcode do
    File.new('/etc/passwd','r').reject{|a| a.start_with? '#'}.map {|b| b.split(':')[0]}.join(',')
  end
end
