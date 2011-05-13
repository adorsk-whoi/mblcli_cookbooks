#
# Cookbook Name:: drush
# Recipe:: default

drush_file_url = "#{node[:drush][:base_url]}#{node[:drush][:version]}.tar.gz"
local_drush_file = "/tmp/drush.tar.gz"

remote_file "#{local_drush_file}" do
  source drush_file_url
  mode "0644"
  checksum node[:drush][:checksum]
end

directory "#{node[:drush][:dir]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "untar-drush" do
  cwd node[:drush][:dir]
  command "tar --strip-components 1 -xzf #{local_drush_file}"
  not_if "/usr/local/bin/drush status drush-version --pipe | grep #{node[:drush][:version]}"
end

link "/usr/local/bin/drush" do
  to "#{node[:drush][:dir]}/drush"
end
