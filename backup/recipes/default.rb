#
# Cookbook Name:: backup
# Recipe:: default
#
# Backup client recipe.

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
old_job_files = `find #{node['backup']['configs_dir']} -type f`.map{|l| l.strip}

# Initialize hash of current job files (current per node's attributes).
current_job_files = {}

# Prepare job definitions for use in the template.
processed_jobs = {}

# Process each job attribute.
node[:backup][:jobs].each do |job_name, job|
    
  # Initialize processed job.
  processed_job = job.to_hash

  # Process job destinations.
  destinations = {}

  # If destinations is not set, set it to 'default'
  if ! job.has_key?('destinations')
    job[:destinations] = 'default'
  end

  # If destinations is 'default', use node defaults.
  if job[:destinations] == 'default'
    destinations = node["backup"]["defaults"]["destinations"].to_hash
    
  # Otherwise if destinations has the key 'from_databag', get destinations from a databag.
  elsif job[:destinations].has_key?('from_databag')
    bag_name = job[:destinations][:from_databag]
    bag = data_bag(job[:destinations][:from_databag])
    
    bag.each do |item_name|
      item = data_bag_item(bag_name, item_name)
      destinations[item_name] = item
    end
    
  # Otherwise get destinations from inline definitions.
  else
    destinations = job["destinations"].to_hash
  end

  # Save destinations to processed job.
  processed_job["destinations"] = destinations

  # If no frequency is set, use node defaults.
  if ! job['frequency']
    job['frequency'] = node["backup"]["defaults"]["frequency"]
  end

  # Path to backup job file that will be written or updated.
  job_file = "#{node['backup']['configs_dir']}/#{job_name}"

  # Write the job file
  template job_file do
    source "backup_job.erb"
    owner "root"
    group "root"
    mode "0750"
    variables(:job_name => job_name, :job => processed_job)
    action :create
  end

  # Create whenever jobs.  Job ids are prefixed w/ '_backup_#{job_name}_'.
  job['frequency'].each do |f|

    # Make frequency hashes for frequency keywords.
    if f.class == String
      if f == 'daily'
        f = {"every" => "1 day"}
      elsif f == 'weekly'
        f = {"every" => "1 week"}
      elsif f == 'monthly'
        f = {"every" => "1 month"}
      end
    end
    
    # Make whenever job from frequency hash
    whenever_job "_backup_#{job_name}" do
      every f['every']
      at f['at'] || "4:20am"
      user 'root'
      command "backup perform --trigger '#{job_name}' --config-file '#{job_file}'"
      action :create
    end

  end

  # Save the processed job.
  processed_jobs[job_name] = processed_job

  # Save job file to hash of new job files.
  current_job_files[job_file] = true

end


# Remove old jobs which are not in current jobs.
old_job_files.each do |job_file|

  if ! current_job_files[job_file]

    # Get job name.
    job_name = File.basename(job_file)

    # Remove corresponding whenever job.
    whenever_job "_backup_#{job_name}" do
      action :delete
    end

    # Remove job file.
    execute "remove defunct backup job file '#{job_file}'" do      
      command "rm -f '#{job_file}'"
    end    

  end
end


