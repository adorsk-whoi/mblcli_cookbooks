#
# Cookbook Name:: drupal
# Attributes:: drupal
#

default[:drupal][:version] = "6.19"
default[:drupal][:checksum] = "b2067b18408321af8595715e2c1fb0e9f20c188b4276bb616c066ff6ab26ee88"
default[:drupal][:dir] = "/var/www/drupal"
default[:drupal][:db][:database] = "drupal"
default[:drupal][:db][:user] = "drupal"

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

set_unless[:drupal][:db][:password] = secure_password
default[:drupal][:src] = Chef::Config[:file_cache_path]
