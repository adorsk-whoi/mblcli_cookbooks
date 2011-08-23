# Build backup job object and set node attributes.
action :create do
  
  # Initialize backup job object.
  job = {}

  # Set name.
  job["name"] = new_resource.name

  # Set description
  job["description"] = new_resource.description || new_resource.name

  # Set file tasks.
  job["file_tasks"] = new_resource.file_tasks

  # Set database tasks.
  job["database_tasks"] = new_resource.database_tasks

  # Set destinations.
  job["destinations"] = new_resource.destinations

  # Set frequency.
  job["frequency"] = new_resource.frequency

  # Add job to node's backup attributes, keyed by name.
  node.set['backup']['jobs'][new_resource.name] = job

end

# Remove backup job from node attributes.
action :delete do
  if ! node['backup']['jobs'][new_resource.name].nil?
    node['backup']['jobs'].delete(new_resource.name)
  end
end

