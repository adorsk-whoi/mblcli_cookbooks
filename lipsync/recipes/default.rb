#
# Cookbook Name:: lipsync
# Recipe:: default
#
# Copyright 2011, Woods Hole Marine Biological Laboratory
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


#install lipsync
cookbook_file "/usr/local/bin/lipsync" do
  source "lipsync.default"
  owner "root"
  group "root"
  mode 0644
end

# install lipsyncd conf from template
template "/etc/lipsyncd" do
  source "lipsyncd.erb"
  owner "root"
  group "root"
  mode 0644
end

# Install init.d script from template
template "/etc/init.d/lipsyncd" do
  source "lipsyncd.init.erb"
  owner "root"
  group "root"
  mode 0755
end

# Install cron.d script from template
template "/etc/cron.d/lipsyncd" do
  source "lipsyncd.cron.erb"
  owner "root"
  group "root"
  mode 0755
end