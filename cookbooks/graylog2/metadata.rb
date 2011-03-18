maintainer        "Medidata Solutions Inc."
maintainer_email  "cloudteam@mdsol.com"
license           "Apache 2.0"
description       "Installs and configures Graylog2"
version           "0.0.4"
recipe            "graylog2", "Installs and configures Graylog2"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ apt apache2 }.each do |pkg|
  depends pkg
end
