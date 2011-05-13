#
# Cookbook Name:: cron
# Recipe:: whenever
#
# Author: Anthony Goddard (<agoddard@mbl.edu>)
# Copyright 2011, Woods Hole Marine Biological Laboratory.
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


def sanitize_every(every)
  if every.include? " "
    every.split.join('.') 
  else
    ":#{every}"
  end
end


node[:cron][:tasks].each_with_index do |task, index|
  
  #ya, we need to get these defaults in a non-insane fashion..
  every = node[:cron][:tasks][index][:every] || node[:cron][:task][:every]
  every = sanitize_every(every)
  at = task[:at] || node[:cron][:task][:at]
  user = task[:user] || node[:cron][:task][:user]
  
  filename = "/tmp/schedule_#{index}.rb"
  
  template filename do
    source "whenever_cron.erb"
    group "root"
    owner "root"
    variables(:task => task[:command], :every => every, :at => at)
    mode 0644
  end

  bash "write_cron" do
    user "root"
    cwd "/tmp"
    code "whenever -i -u #{user} -f #{filename}"
  end
end


#TODO
# splay-ish