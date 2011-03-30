#global
default[:lipsync][:version] = "current"

#local
default[:lipsync][:local][:user] = "lipsync"
default[:lipsync][:local][:directory] = '/sync'
default[:lipsync][:local][:public_key] = ""

#remote
default[:lipsync][:remote][:user] = "lipsync"
default[:lipsync][:remote][:host] = "127.0.0.1"
default[:lipsync][:remote][:port] = "22"
default[:lipsync][:remote][:directory] = '/sync'



