#
# Cookbook Name:: drush
# Recipe:: default

# Include dependencies.
include_recipe %w{php}

drush_file_url = "#{node[:drush][:base_url]}#{node[:drush][:version]}.tar.gz"
tmp_drush_file = "/tmp/drush.tar.gz"

drush_test_command = "drush status drush-version --pipe | grep -q #{node[:drush][:version]}"

# Create drush directory if it does not yet exist.
directory "drush directory" do
  path node[:drush][:dir]
  owner "root"
  group "root"
  mode "0755"
end

# Only download drush if we don't have the appropriate version installed.
# Triggers subsequent drush installation commands.
execute "download drush" do
  command "wget #{drush_file_url} -O #{tmp_drush_file}"
  not_if "#{drush_test_command}"
  notifies :run, "execute[untar drush]", :immediately
end

execute "untar drush" do
  cwd node[:drush][:dir]
  command "tar --strip-components 1 -xzf #{tmp_drush_file}"
  notifies :run, "execute[rm tmp drush file]", :immediately
  action :nothing
end

execute "rm tmp drush file" do
  command "rm #{tmp_drush_file}"
  notifies :create, "link[/usr/local/bin/drush]", :immediately
  action :nothing
end

link "/usr/local/bin/drush" do
  to "#{node[:drush][:dir]}/drush"
  action :nothing
  notifies :run, "execute[test drush]", :immediately
end


execute "test drush" do
  command "#{drush_test_command}"
  action :nothing
end
