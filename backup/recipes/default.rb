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

# Prepare job definitions for use in the template.
processed_jobs = {}

if ! node[:backup][:jobs].nil?
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
        command "backup perform --trigger #{job_name} --config-file #{node[:backup][:config_file]}"
        action :create
      end

    end

    # Save the processed job.
    processed_jobs[job_name] = processed_job

  end
end

# Write the backup config file.
template "#{node[:backup][:config_file]}" do
  owner "root"
  group "root"
  mode "0750"
  variables(:jobs => processed_jobs)
  action :create
  not_if {processed_jobs.nil?}
end

