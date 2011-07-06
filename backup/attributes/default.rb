#
# Cookbook Name:: backup
# Attributes:: backup
#

default[:backup][:config] = "/etc/backup.cfg"
default[:backup][:key_file] = "/root/.ssh/id_dsa.pub"
default[:backup][:default_destinations] = {}

default[:backup_manager][:backup_dir] = "/data/backups"
default[:backup_manager][:client_search_index] = "node"
default[:backup_manager][:client_search_query] = 'run_list:recipe\[backup\]'
