#
# Cookbook Name:: whenever
# Recipe:: default
#
# Author: Anthony Goddard (<agoddard@mbl.edu>), modified by adorsk-whoi.
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

# Install gem dependencies.
gem_package "i18n" do
  action :install
end

gem_package "whenever" do
  action :install
end

# Make sure cron directory exists for whenever
directory "/etc/cron.whenever" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

# Helper function to santize the 'every' parameter.
def sanitize_every(every)
  if every.include? " "
    every.split.join('.') 
  else
    ":#{every}"
  end
end

# Process each job attribute.
node["whenever"]["jobs"].each do |id, job|
  
  # Get 'every' or use defaults.
  every = job['every'] || node['whenever']['defaults']['every']
  every = sanitize_every(every)
  
  # Get 'at'.
  at = job['at'] || node['whenever']['defaults']['at']

  # Get 'user'.
  user = job['user'] || node['whenever']['defaults']['user']

  # Path to temporary whenever config file.
  whenever_file = "/tmp/_whenever_#{id}.rb"
  
  # Write temporary file.
  template whenever_file do
    source "whenever_job.erb"
    group "root"
    owner "root"
    variables(:command => job['command'], :every => every, :at => at)
    mode 0644
  end

  # Generate cron jobs from the config file.
  execute "whenever to cron" do
    command "whenever -i -u #{user} -f #{whenever_file}"
  end
end
