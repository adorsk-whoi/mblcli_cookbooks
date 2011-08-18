#
# Cookbook Name:: backup
# Attributes:: backup
#

default[:backup][:config] = "/etc/backup.cfg"

default[:backup][:defaults][:destinations] = {}
default[:backup][:defaults][:frequency] = ["daily"]

default[:backup][:manager][:backup_dir] = "/data/backups"
default[:backup][:manager][:client_search_index] = "node"
default[:backup][:manager][:client_search_query] = 'run_list:recipe\[backup\]'
