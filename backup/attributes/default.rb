#
# Cookbook Name:: backup
# Attributes:: backup
#

set[:backup][:config] = "/etc/backup.cfg"
set[:backup][:key_file] = "~root/.ssh/id_dsa.pub"
