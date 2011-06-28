#
# Cookbook Name:: backup
# Recipe:: default
#
# Main backup recipe.

gem_package "backup" do
  action :install
end


# Try to set the node's backup key attribute.
begin

  # Get the node's backup key.
  backup_key = File.open(node[:backup][:key_file], "rb").read()
  
  # Set the backup key attribute.
  node.set['backup']['key'] = backup_key
rescue
end



# Write the backup config file.
template "#{node[:backup][:config]}" do
  owner "root"
  group "root"
  mode "0750"
  variables(:jobs => node[:backup][:jobs])
  action :create
  not_if {node[:backup][:jobs].nil?}
end

