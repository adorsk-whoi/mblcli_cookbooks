def initialize(*args)
  super
  @action = :create
end

# Build whenever job object and set node attributes.
action :create do
  
  # Initialize backup job object.
  job = {}

  # Set 'every', 'at', 'user', and 'command'
  job["every"] = new_resource.every
  job["at"] = new_resource.at
  job["user"] = new_resource.user
  job["command"] = new_resource.command

  # Add job to node's backup attributes, keyed by name.
  node.set['whenever']['jobs'][new_resource.name] = job

end

# Remove whenever job from node attributes.
action :delete do
  if ! node['whenever']['jobs'][new_resource.name].nil?
    node['whenever']['jobs'].delete(new_resource.name)
  end
end

