name             "heat"
maintainer       "Rackspace US, Inc."
license          "Apache 2.0"
description      "Installs/Configures heat"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "4.2.0"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ apt database mysql apache2 }.each do |dep|
  depends dep
end

depends 'openstack-common', '~> 8.0'
