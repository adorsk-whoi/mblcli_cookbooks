maintainer       "adorsk-whoi"
maintainer_email "adorsk@whoi.edu"
license          "All rights reserved"
description      "Runs backups."
version          "0.0.1"

%w{ debian ubuntu }.each do |os|
  supports os
end

%w{ssh_key}.each do |cb|
  depends cb
end
