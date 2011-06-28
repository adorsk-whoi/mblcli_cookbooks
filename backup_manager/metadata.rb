description      "Installs/Configures drush"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
recipe           "backup_manager", "Configures a node as a backup manager."

%w{ debian ubuntu }.each do |os|
  supports os
end

