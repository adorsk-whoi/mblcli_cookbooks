#
# Cookbook Name:: backup
# Recipe:: default
#
# Main backup recipe.

gem_package "backup" do
  action :install
end

# Try to set the node's backup key attribute.
begin

  # Get the node's backup key.
  backup_key = File.open(node[:backup][:key_file], "rb").read()
  
  # Set the backup key attribute.
  node.set['backup']['key'] = backup_key

rescue
end


##
## @todo: could set destination by doing a search for all the nodes w/ runlist backup_manager who have the client node in its list of clients.  For each of those nodes, make a storage destination in the template.


# Prepare job definitions for use in the template.
processed_jobs = {}
node[:backup][:jobs].each do |job_name, job|
  
  # Initialize processed job.
  processed_job = job.to_hash

  # Process job destinations.
  destinations = {}

  # If destinations is 'default', use node defaults.
  if job[:destinations] == 'default'
    destinations = node["backup"]["default_destinations"].to_hash

  # Otherwise if destinations has the key 'from_databag', get destinations from a databag.
  elsif job[:destinations].has_key?('from_databag')
    bag_name = job[:destinations][:from_databag]
    bag = data_bag(job[:destinations][:from_databag])

    bag.each do |item_name|
      destinations[item_name] = data_bag_item(bag_name, item_name)
    end

  # Otherwise get destinations from inline definitions.
  else
    destinations = job["destinations"].to_hash
  end

  # Save destinations to processed job.
  processed_job["destinations"] = destinations

  # Save the processed job.
  processed_jobs[job_name] = processed_job

end

# Write the backup config file.
template "#{node[:backup][:config]}" do
  owner "root"
  group "root"
  mode "0750"
  variables(:jobs => processed_jobs)
  action :create
  not_if {processed_jobs.nil?}
end

