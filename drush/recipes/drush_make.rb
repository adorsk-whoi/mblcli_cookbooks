#
# Cookbook Name:: drush
# Recipe:: drush_make
# Description: Installs drush make.
#

# Set name of drush make to download, per attributes.
drush_make_name = "drush_make"

if node.attribute?("drush") && node.drush.attribute?("drush_make") && node.drush.drush_make.attribute?("version")

  drush_make_name += "-#{node[:drush][:drush_make][:version]}"

end

execute "install-drush_make" do
  command "drush dl -y --destination=#{node[:drush][:dir]}/commands/drush_make #{drush_make_name}; drush --pipe|grep -q make"
  not_if 'drush --pipe |grep -q " make "'
end
