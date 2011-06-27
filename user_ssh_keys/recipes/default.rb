#
# Cookbook Name:: user_ssh_keys
# Recipe:: default
#

# For each databag to scan...
node[:user_ssh_keys][:databags].each do |databag|

  # Get users from databag.
  users = data_bag(databag)

  # For each user...
  users.each do |user|

    # Get user config item from databag.
    user_config = data_bag_item(databag, user)

    # If user has ssh configs...
    if (! user_config["ssh_keys"].nil?)

      # ssh key type must be 'rsa' or 'dsa'.
      if (user_config["ssh_keys"]["type"].nil? ||
          user_config["ssh_keys"]["type"] !~ /^(dsa|rsa)$/ ) 
        raise "Must specify type of ssh key as either rsa or dsa.  Databag: '#{databag}', item: '#{user}'."  
      end

      # Shortcut for key type.
      key_type = user_config["ssh_keys"]["type"]

      # Shortcut for user ssh directory.
      ssh_dir = `echo ~#{user}/.ssh`.chomp!

      # Create .ssh directory if it does not exist.
      Directory "#{ssh_dir}" do
        owner "#{user}"
        group "#{user}"
        mode "0700"
      end

      # If user has public key, write it to user's .ssh dir.
      if (! user_config["ssh_keys"]["public"].nil?)
        File "#{ssh_dir}/id_#{key_type}.pub" do
          owner "#{user}"
          group "#{user}"
          mode "0744"
          content user_config["ssh_keys"]["public"]
        end
      end


      # If user has private key, write it to user's .ssh dir.
      if (! user_config["ssh_keys"]["private"].nil?)
        File "#{ssh_dir}/id_#{key_type}" do
          owner "#{user}"
          group "#{user}"
          mode "0700"
          content user_config["ssh_keys"]["private"]
        end
      end


    end
  end


end unless node[:user_ssh_keys][:databags].nil?
