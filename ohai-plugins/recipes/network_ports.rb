# Author:: Anthony Goddard <agoddard@mbl.edu>
# Cookbook Name:: ohai-plugins
# Recipe:: default
#
# Copyright 2011, Marine Biological Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0644"
  variables :mon_host => mon_host
  notifies :restart, resources(:service => "nagios-nrpe-server")
end