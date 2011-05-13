maintainer       "adorsk-whoi"
maintainer_email "adorsk@whoi.edu"
license          "All rights reserved"
description      "Installs/Configures Aegir environment"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"


%w{apache2 mysql apt drush}.each do |cb|
  depends cb
end
