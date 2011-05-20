#
# Cookbook Name:: taxonfinder
# Recipe:: default
#
# Copyright 2011, Woods Hole Marine Biological Laboratory
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

directory "#{node[:taxonfinder][:dir]}" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

remote_file "#{node[:taxonfinder][:dir]}/taxon-finder.tar.gz" do
  source "#{node[:taxonfinder][:src]}"
  mode "0644"
  checksum node[:taxonfinder][:checksum]
  action :create_if_missing
end

execute "untar-taxonfinder" do
  cwd node[:taxonfinder][:dir]
  command "tar --strip-components=1 -xzf #{node[:taxonfinder][:dir]}/taxon-finder.tar.gz"
end

template "#{node[:taxonfinder][:dir]}/config.pl" do
  source "config.pl.erb"
end

file "#{node[:taxonfinder][:dir]}/taxon-finder.tar.gz" do
  action :delete
end