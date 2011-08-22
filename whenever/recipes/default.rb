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



# Helper function to santize the 'every' parameter.
def sanitize_every(every)
  if every.include? " "
    every.split.join('.') 
  else
    ":#{every}"
  end
end



# Install gem dependencies.
gem_package "i18n" do
  action :install
end

gem_package "whenever" do
  action :install
end

# Make sure directory exists for whenever config files.
directory "#{node['whenever']['configs_dir']}" do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end

# Get list of existing whenever job files.
existing_job_files = `find #{node['whenever']['configs_dir']} -type f`.map{|l| l.strip}

# Remove defunct jobs which are not in the node attributes.
existing_job_files.each do |job_file|

  job_id = File.basename(job_file, File.extname(job_file))

  if ! node['whenever']['jobs'][job_id]
    execute "remove defunct whenever job '#{job_id}'" do
      command "whenever -c -f #{job_file}; rm -f #{job_file}"
    end    
  end
end

# Process each job attribute.
node["whenever"]["jobs"].each do |job_id, job|
  
  # Get 'every' or use defaults.
  every = job['every'] || node['whenever']['defaults']['every']
  every = sanitize_every(every)
  
  # Get 'at'.
  at = job['at'] || node['whenever']['defaults']['at']

  # Get 'user'.
  user = job['user'] || node['whenever']['defaults']['user']

  # Path to temporary whenever config file.
  whenever_file = "#{node['whenever']['configs_dir']}/#{job_id}.rb"
  
  # Write job file and notify execution of whenever update command.
  template "#{whenever_file}" do
    source "whenever_job.erb"
    group "root"
    owner "root"
    variables(:command => job['command'], :every => every, :at => at)
    mode 0644
    notifies :run, "execute[update whenever job '#{job_id}']"
  end

  # Update crontab from whenever job files.
  execute "update whenever job '#{job_id}'" do
    command "whenever -i -f #{whenever_file}"
    action :nothing
  end
end
