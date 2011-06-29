#
# Cookbook Name:: backup
# Attributes:: backup
#

default[:backup][:config] = "/etc/backup.cfg"
default[:backup][:key_file] = "/root/.ssh/id_dsa.pub"
default[:backup][:default_destinations] = {}
