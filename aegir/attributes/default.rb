#
# Cookbook Name:: aegir
# Attributes:: aegir
#

include_attribute "mysql::server"
include_attribute "drush"
include_attribute "php"

# General settings
default[:aegir][:domain] = "#{node[:fqdn]}"
default[:aegir][:client_email] = "root@#{node[:fqdn]}"
default[:aegir][:db_user] = 'root'
default[:aegir][:db_pass] = "#{node[:mysql][:server_root_password]}"

# Drush (requires at least 4.4)
override[:drush][:version] = "4.4"
override[:drush][:base_url] = "http://ftp.drupal.org/files/projects/drush-7.x-"
override[:drush][:checksum] = "b8f89ee75a8d45a4765679524ebdf8b4"

# Drush make 6-x
override[:drush][:drush_make][:version] = "6.x"

# PHP CLI (requires at least 192M)
override[:php][:cli][:memory_limit] = "-1"
