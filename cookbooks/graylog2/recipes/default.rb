#
# Cookbook Name:: graylog2
# Recipe:: default
#
# Copyright 2010, Medidata Solutions Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add apt public key for mongodb repo
execute "get_mongodb_pubkey" do
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
  not_if 'apt-key list | grep "7F0CEB10"'
  action :nothing
end

# Add mongodb repository to apt
apt_repository "mongoDB" do
  uri "http://downloads.mongodb.org/distros/ubuntu"
  distribution "10.4"
  components ["10gen"]
  action :add
  notifies :run, "execute[get_mongodb_pubkey]", :immediately
end

# Install required apt packages
%w{ openjdk-6-jre mongodb-stable }.each do |pkg|
  package pkg do
    action :install
  end
end

# Create application directory
directory "#{node[:graylog2][:basedir]}/src" do
  owner "root"
  group "root"
  mode 0755
  action :create
  recursive true
end

# Use remote_file to grab the desired version of graylog2-server package
remote_file "graylog2_server" do
  path "#{node[:graylog2][:basedir]}/src/graylog2-server-#{node[:graylog2][:serverversion]}.tar.gz"
  source "https://github.com/downloads/Graylog2/graylog2-server/graylog2-server-#{node[:graylog2][:serverversion]}.tar.gz"
  action :create_if_missing
end

# Unpack graylog2-server
execute "unpack_graylog2_server" do
  cwd "#{node[:graylog2][:basedir]}/src"
  command "tar zxf graylog2-server-#{node[:graylog2][:serverversion]}.tar.gz"
  creates "#{node[:graylog2][:basedir]}/src/graylog2-server-#{node[:graylog2][:serverversion]}/build_date"
  subscribes :run, resources(:remote_file => "graylog2_server"), :immediately
end

# Link graylog2-server
link "#{node[:graylog2][:basedir]}/server" do
  to "#{node[:graylog2][:basedir]}/src/graylog2-server-#{node[:graylog2][:serverversion]}"
end

# Install graylog.conf from template
template "/etc/graylog2.conf" do
  source "graylog2.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# Install init.d script
template "/etc/init.d/graylog2" do
  source "graylog2.init.erb"
  owner "root"
  group "root"
  mode 0755
end

# Update the rc.d system for graylog
execute "update-rcd-graylog2" do
  command "update-rc.d graylog2 defaults"
  creates "/etc/rc0.d/K20graylog2"
  notifies :enable, "service[graylog2]", :immediately
  notifies :start, "service[graylog2]", :delayed
end

# Service def for graylog2
service "graylog2" do
  supports :restart => true
  action :enable
end
