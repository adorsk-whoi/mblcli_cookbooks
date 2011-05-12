
# Install php5-cli via package.
package "php5-cli" do
  action :install
end

# Set the memory limit if on ubuntu or debian.
case node[:platform]

when "debian","ubuntu"
  execute "php cli memory limit" do
    command "sed -i 's/memory_limit = .*/memory_limit = #{node[:php][:cli][:memory_limit]}/' /etc/php5/cli/php.ini"
  end
end
