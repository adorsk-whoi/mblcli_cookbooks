#
# Cookbook Name:: backup
# Recipe:: default
#
# Backup client recipe and setup.

include_recipe %w{ssh_key}

# Setup ssh key for root if no key exists.
ssh_key "root key" do
  user "root"
  type "dsa"
  action :create_if_missing
end

# Install the backup gem.
gem_package "backup" do
  action :install
end

# Make sure directory exists for backup config files.
directory "#{node['backup']['configs_dir']}" do
  owner "root"
  group "root"
  mode 0700
  recursive true
  action :create
end



# Get list of existing backup job files.
old_jobs = `find #{node['backup']['configs_dir']} -type f`.map{|l| File.basename(l.strip)}

# Initialize hash of current job files (current per node's attributes).
current_jobs = {}

# Process each job attribute.
node[:backup][:jobs].each do |job_name, job|
    
  backup_job "#{job_name}" do
    description job["description"]
    file_tasks job["file_tasks"]
    database_tasks job["database_tasks"]
    destinations job["destinations"]
    frequency job["frequency"]
    action :create
  end

  # Save job file to hash of new job files.
  current_jobs[job_name] = true

end


# Remove old jobs which are not in current jobs.
old_jobs.each do |job_name|

  if ! current_jobs[job_name]

    backup_job "#{job_name}" do
      action :delete
    end

  end
end


