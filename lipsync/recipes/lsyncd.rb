#only supporting debian in the beginning..
# remote_file "/usr/local/src/lsyncd-#{node.lipsync.lsyncd.version}.tar.gz" do
#   source node.lipsync.lsyncd.uri
#   # checksum?
# end
# 
# execute "untar lsyncd" do
#   command "tar xzf lsyncd-#{node.lipsync.lsyncd.version}.tar.gz"
#   creates "/usr/local/src/lsyncd-#{node.lipsync.lsyncd.version}"
#   cwd "/usr/local/src"
# end

# execute "install lsyncd" do
  # command "./configure"
  # creates #TODO
  # cwd "/usr/src/lsyncd-#{node.lipsync.lsyncd.version}"
# end