#
# Cookbook Name:: cobbler
# Recipe:: default
#
# Copyright 2010, Bryan McLellan <btm@loftninjas.org>
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

include_recipe "apache2"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_python"

%w{ python-yaml python-cheetah python-netaddr python-urlgrabber syslinux git-core }.each do |pack|
  package pack
end

directory "/opt" do
  owner "root"
  group "root"
  mode "0755"
end

git "/opt/cobbler-source" do
  repository "git://github.com/proffalken/cobbler.git"
  action :sync
end

execute "build-cobbler" do
  command "make"
  cwd "/opt/cobbler-source"
  action :nothing
  not_if { File.exists?("/usr/local/bin/cobbler") }
end

execute "install-cobbler" do
  command "python setup.py install"
  cwd "/opt/cobbler-source"
  action :nothing
  not_if { File.exists?("/usr/local/bin/cobbler") }
  notifies :restart, resources(:service => "apache2")
end

runit_service "cobbler"

template "/etc/cobbler/settings" do
  source "settings.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "cobbler")
  variables(
    :server => node[:fqdn],
    :virt => "kvm",
    :bridge => "br0"
  )
end

template "/etc/apache2/conf.d/cobbler.conf" do
  source "apache.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "apache2")
end

link "/tftpboot" do
  to "/var/lib/tftpboot"
end

