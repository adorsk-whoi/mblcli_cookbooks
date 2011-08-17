#
# Cookbook Name:: aegir
# Recipe:: default
#
# Main setup recipe for the Aegir hosting environment.
# Assumes that aegir is on a dedicated server.

# Include required recipes.
#include_recipe %w{apt mysql::server apache2 php php::mysql git drush drush::drush_make}
include_recipe %w{apt mysql::server apache2 php php::mysql php::gd git drush drush::drush_make}

# Install required packages.
# @todo: separate recipes for these later?
package "rsync"
package "postfix"
package "unzip"

# apache: enable mod_rewrite
apache_module "rewrite" do
  enable true
end

# Create aegir system user.
user "aegir" do
  comment "aegir"
  system true
  shell "/bin/false"
  home "/var/aegir"
end

# Add aegir user to apache group.
group "aegir apache group" do
  group_name node[:apache][:user]
  members ['aegir']
  append true
end

# Make aegir dir.
directory "/var/aegir" do
  group "aegir"
  owner "aegir"
  recursive true
end

# Allow aegir user to restart apache.
execute "aegir sudo conf" do
  command "echo 'aegir ALL=NOPASSWD: /usr/sbin/apache2ctl' | sudo tee -a /etc/sudoers"
  not_if "grep -q aegir /etc/sudoers"
end

# Create link to aegir conf to apache conf dir.
link "aegir conf" do
  target_file "#{node[:apache][:dir]}/conf.d/aegir.conf"
  to "/var/aegir/config/apache.conf"
end 


# Install provision
execute "install provision" do
  command 'su -s /bin/sh aegir -c "drush dl provision-6.x"'
  not_if "test -d /var/aegir/.drush/provision"
end

# Install hostmaster
execute "install hostmaster" do
  command "su -s /bin/sh aegir -c \"drush -y hostmaster-install --aegir_db_user=#{node[:aegir][:db_user]} --aegir_db_pass=#{node[:aegir][:db_pass]} --client_email=#{node[:aegir][:client_email]} #{node[:aegir][:domain]}\""
  not_if "ls -1 /var/aegir | grep -q hostmaster"
end




