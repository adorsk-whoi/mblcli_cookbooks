#global
default[:lipsync][:version] = "current"
default[:lipsync][:logfile] = "/var/log/lipsyncd.log"

#local
default[:lipsync][:local][:user] = "lipsync"
default[:lipsync][:local][:directory] = '/sync'
default[:lipsync][:local][:public_key] = ""

#remote
default[:lipsync][:remote][:user] = "lipsync"
default[:lipsync][:remote][:host] = "127.0.0.1"
default[:lipsync][:remote][:port] = "22"
default[:lipsync][:remote][:directory] = '/sync'

#lsyncd
default[:lipsync][:lsyncd][:version] = "2.0.3"
default[:lipsync][:lsyncd][:uri] = "http://lsyncd.googlecode.com/files/lsyncd-#{default[:lipsync][:lsyncd][:version]}.tar.gz"


