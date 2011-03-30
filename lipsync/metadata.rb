maintainer       "Woods Hole Marine Biological Laboratory"
maintainer_email "agoddard@mbl.edu"
license          "Apache 2.0"
description      "Installs/Configures lipsync"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ ubuntu debian }.each do |os|
  supports os
end