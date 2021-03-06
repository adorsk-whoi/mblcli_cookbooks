#
# Cookbook Name:: backup
# Recipe:: default
#
# Main backup recipe.

gem_package "backup" do
  action :install
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