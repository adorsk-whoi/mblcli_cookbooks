#
# Cookbook Name:: backups
# Recipe:: default
#
# Main backups recipe.

# Include dependencies.
include_recipe %w{}

# Define templates inline for now.
# Should probably be moved to a separate file later for cleanliness.

backup_template=<<-'eos'
Backup::Model.new(:<%= backup_name %>, '<%= backup_config[:description] %>') do
  # Adapters
  <% rendered_adapters.each do |rendered_adapter| %><%= rendered_adapter %><% end %>
  # Storages
  <% rendered_storages.each do |rendered_storage| %><%= rendered_storage %><% end %>
end
eos

archive_template=<<-'eos'

  archive :<%= archive_name %> do |archive|
    <% archive_config[:includes].each do |path| %>archive.add '<%= path %>'<% end %>
    <% archive_config[:excludes].each do |path| %>archive.exclude '<%= path %>'<% end %>
  end

eos


rsync_template=<<-'eos'

  store_with RSync do |server|
    <% rsync_config.each do |k, v| %><%= "#{k} = '#{v}'" %>
    <% end %>
  end

eos



# Make backup configs dir if it does not exist.
directory "#{node[:backups][:configs_dir]}" do
  owner "root"
  group "root"
  mode "0750"
  recursive true
  action :create
end


# For each backup namespace specified in the node's backup triggers attributes...
node.backups.triggers.each do |backup_name, backup_config|
  
  #
  # Render the adapters.
  #

  ## NOTE: everything is inline for now, but could probably separate templates and make some sort of nifty dispatcher for rendering each adapter.  To avoid code repitition.

  # Initialize a list to hold rendered adapters.
  rendered_adapters = []

  # Render 'archives' adpaters.
  backup_config[:adapters][:archives].each do |archive_name, archive_config|

    # Save scope of this block for rendering.
    archive_binding = binding

    # Render archive adapter.
    rendered_archive_adapter = ERB.new(archive_template).result(archive_binding)

    # Save the rendered adapter to the list.
    rendered_adapters.push(rendered_archive_adapter)
    
  end
  
  # Other adapter processing here...

  
  #
  # Render storages.
  #
  
  ## NOTE: ditto the adapters note above.

  # Initialize a list to hold rendered storages.
  rendered_storages = []

  # Render 'RSync' storages.
  backup_config[:storages][:RSync].each do |rsync_name, rsync_config|

    # Save scope of this block for rendering.
    rsync_binding = binding

    # Render rsync storage
    rendered_rsync_storage = ERB.new(rsync_template).result(rsync_binding)

    # Save the rendered adapter to the list.
    rendered_storages.push(rendered_rsync_storage)
    
  end


  #
  # Render the full trigger.
  #

  # Save the current scope for rendering the full backup trigger.
  backup_binding = binding

  # Render the full backup trigger.
  rendered_trigger = ERB.new(backup_template).result(backup_binding)
  

  # Write the trigger to a file.
  file "#{node[:backups][:configs_dir]}/#{backup_name}" do
    owner "root"
    group "root"
    mode "0750"
    content rendered_trigger
    action :create
  end

end
