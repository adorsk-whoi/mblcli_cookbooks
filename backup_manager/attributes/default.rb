#
# Cookbook Name:: backup_manager
# Attributes:: backup_manager
#

default[:backup_manager][:backup_dir] = "/data/backups"
default[:backup_manager][:client_search_index] = "node"
default[:backup_manager][:client_search_query] = 'run_list:recipe\[backup\]'
