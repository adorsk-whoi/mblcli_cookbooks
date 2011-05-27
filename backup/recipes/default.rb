#
# Cookbook Name:: backup
# Recipe:: default
#
# Main backup recipe.

# Include dependencies.
include_recipe %w{}

# Write the backup config file.
template "#{node[:backup][:config]}" do
  owner "root"
  group "root"
  mode "0750"
  content rendered_trigger
  action :create
end