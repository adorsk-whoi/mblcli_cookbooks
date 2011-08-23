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

# Get list of existing old whenever job files.
old_job_files = `find #{node['whenever']['configs_dir']} -type f`.map{|l| l.strip}

# Initialize hash of current job files (current per node's attributes).
current_job_files = {}

# Process each job attribute.
node["whenever"]["jobs"].each do |job_id, job|
  
  # Get 'every' or use defaults.
  every = job['every'] || node['whenever']['defaults']['every']
  every = sanitize_every(every)
  
  # Get 'at'.
  at = job['at'] || node['whenever']['defaults']['at']

  # Get 'user'.
  user = job['user'] || node['whenever']['defaults']['user']

  # Path to whenever schedule file that will be written or updated.
  # Note: filename convention is '_job_job_id-_user_username'.  We use this convention
  # in order to detect changes in job user attributes.
  whenever_file = "#{node['whenever']['configs_dir']}/__job:#{job_id}__user:#{user}"
  
  # Write job file and notify execution of whenever update command.
  template whenever_file do
    source "whenever_job.erb"
    group "root"
    owner "root"
    variables(:command => job['command'], :every => every, :at => at)
    mode 0644
    notifies :run, "execute[update whenever job '#{whenever_file}']"
  end

  # Update crontab from whenever job files.
  execute "update whenever job '#{whenever_file}'" do
    command "whenever -u #{user} -i -f '#{whenever_file}'"
    action :nothing
  end

  # Save whenever file to hash of new job files.
  current_job_files[whenever_file] = true

end


# Remove old jobs which are not in current jobs.
old_job_files.each do |job_file|

  if ! current_job_files[job_file]

    # Extract the user and job_id from the job file name.
    if File.basename(job_file) =~ /^__job:(.*)__user:(.*)$/
      user = $2
      execute "remove defunct whenever job '#{job_file}'" do
        command "whenever -u '#{user}' -c -f '#{job_file}'; rm -f '#{job_file}'"
      end    
    end

  end
end
