#
# Cookbook Name:: graylog2
# Recipe:: web-interface
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

# Install graylog2 server
include_recipe "graylog2::default"

# Ensure bundler is available
gem_package "bundler" do
  version "1.0.3"  # Put in for our infrastructure requirements at MDSOL
  action :install
end

# Ensure rake is available
gem_package "rake" do
  action :install
end

# Install required apt packages
%w{ build-essential make rrdtool rake libopenssl-ruby ruby-dev postfix }.each do |pkg|
  package pkg do
    action :install
  end
end

# Make sure app directory exists
directory "#{node[:graylog2][:basedir]}/src" do
  owner "root"
  group "root"
  mode 0755
  action :create
  recursive true
end

# Use remote_file to grab the desired version of graylog2-web-interface
remote_file "graylog2_webui" do
  path "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz"
  source "https://github.com/downloads/Graylog2/graylog2-web-interface/graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz"
  action :create_if_missing
end

# Unpack graylog2-web-interface
execute "unpack_graylog2_webui" do
  cwd "#{node[:graylog2][:basedir]}/src"
  command "tar zxf graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz"
  creates "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}/build_date"
end

# Link graylog2-web-interface
link "graylog2_webui" do
  target_file  "#{node[:graylog2][:basedir]}/web"
  to "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}"
end

# Perform bundle install on newly-installed webui rails project
execute "webui_bundle" do
  cwd "#{node[:graylog2][:basedir]}/web"
  command "bundle install"
  action :nothing
  subscribes :run, resources(:link => "graylog2_webui"), :immediately
end

cron "Graylog2 send stream alarms" do
  minute "*/15"
  command "cd #{node[:graylog2][:basedir]}/web && RAILS_ENV=production bundle exec rake streamalarms:send"
end

cron "Graylog2 send subscriptions" do
  minute "*/15"
  command "cd #{node[:graylog2][:basedir]}/web && RAILS_ENV=production bundle exec rake subscriptions:send"
end

# Create rails app configs
%w{ mongoid general }.each do |conf|
  template "webui_#{conf}_config" do
    path "#{node[:graylog2][:basedir]}/web/config/#{conf}.yml"
    source "#{conf}.yml.erb"
    owner "nobody"
    group "nogroup"
    mode 0644
  end
end

# Chown the graylog2 directory to nobody/nogroup to allow web servers to serve it
execute "webui_chown" do
  cwd "#{node[:graylog2][:basedir]}/src"
  command "sudo chown -R nobody:nogroup graylog2-web-interface-#{node[:graylog2][:webuiversion]}"
  not_if do
    File.stat("#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}").uid == 65534
  end
end
