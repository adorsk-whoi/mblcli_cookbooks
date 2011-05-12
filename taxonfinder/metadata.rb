maintainer       "Anthony Goddard"
maintainer_email "agoddard@mbl.edu"
license          "Apache 2.0"
description      "Installs/Configures taxonfinder"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ perl }.each do |cb|
  depends cb
end

%w{ centos debian ubuntu }.each do |os|
  supports os
end