#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: drupal
# Recipe:: drush
#
# Copyright 2010, Promet Solutions
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

include_recipe %w{php::mysql}

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

execute "install-drush-make" do
  cwd node[:drush][:dir]
  command "/usr/local/bin/drush dl --destination=#{node[:drush][:dir]}/commands/drush_make drush_make-#{node[:drush][:drush_make][:version]}"
  not_if { File.directory?("/root/.drush/drush_make")}
end
