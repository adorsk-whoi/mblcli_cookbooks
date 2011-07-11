#
# Cookbook Name:: backup_manager
# Recipe:: default
#

# Make backups parent directory.
directory "#{node[:backup][:manager][:backup_dir]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# Get current list of backup clients to service.
clients = search(node[:backup][:manager][:client_search_index], node[:backup][:manager][:client_search_query])

# Get old list of backup clients we service from node attributes.
old_client_list = []
if node[:backup][:manager].attribute?("clients")
  old_client_list = node[:backup][:manager][:clients]
end

# Remove clients which are not in the current list.
# REMOVE DEFUNCT CLIENTS HERE!

# For each node in the current list...
clients.each do |client|
  
  # Use first 32 characters of client's name as the username.
  client_name = client.name
  user_name = "%.32s" % client_name

  # Generate the path of the client's storage folder
  storage_folder = "#{node[:backup][:manager][:backup_dir]}/#{user_name}"

  # Make a user.
  user "#{user_name}" do
    comment "#{client_name} backup user"
    home "#{storage_folder}"
    shell "/bin/bash"
  end

  # Make a directory, readable only by the user.
  directory "#{storage_folder}" do
    owner "#{user_name}"
    group "#{user_name}"
    mode "0700"
    action :create
  end
  
  # Create .ssh folder if it does not exist.
  directory "#{storage_folder}/.ssh" do
    owner "#{user_name}"
    group "#{user_name}"
    mode "0700"
    action :create
  end

  # Add the client's backup key to the user's authorized_keys file.
  keys_file = "#{storage_folder}/.ssh/authorized_keys"
  client_key = ""
  if client.attribute?('backup') && client[:backup].attribute?('key')
    client_key = client[:backup][:key]
  end

  execute "add key for #{client_name}" do
    command "echo '#{client_key}' >> #{keys_file}; chown #{user_name}:#{user_name} #{keys_file}; chmod 700 #{keys_file}"
    only_if "! test -f #{keys_file} || grep -q -v '#{client_key}' #{keys_file}"
  end

end

