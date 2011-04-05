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

gem_package "whenever" do
  action :install
end


# TODO permit :day, :week, :minute, :hour etc..
# every [:node][:cron][:frequency].[:node][:cron][:unit], :at => "'#{[:cron][:time][:hour]}:#{[:cron][:time][:minute]}" do
#   node[:cron][:rake] if node[:cron][:rake]
#   node[:cron][:runner] if node[:cron][:runner]
#   node[:cron][:command] if node[:cron][:command]
# end