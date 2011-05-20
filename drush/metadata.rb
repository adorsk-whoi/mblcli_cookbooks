description      "Installs/Configures drush"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
recipe           "drush", "Installs and configures Drush"

%w{ php }.each do |cb|
  depends cb
end

%w{ debian ubuntu }.each do |os|
  supports os
end

