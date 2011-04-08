#
# Cookbook Name:: cron
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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

gem_package "i18n" do
  action :install
end

gem_package "whenever" do
  action :install
end



# Make sure cron directory exists
directory "/etc/cron.whenever" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

# not quite ready for primetime
# TODO write user specific files
template "/etc/cron.whenever/whenever.rb" do
  source "whenever_cron.erb"
  group "root"
  owner "root"
  variables :cron => node[:cron]
  mode 0644
  # notifies :restart, resources(:service => "apache2")
end


#TODO
# command: whenever -u @user -i -f whenever.rb
# splay-ish