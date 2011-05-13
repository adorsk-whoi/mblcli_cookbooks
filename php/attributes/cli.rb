#
# Cookbook Name:: php
# Attribute:: cli
#

# Set the php cli memory limit.
default_unless['php']['cli']['memory_limit'] = '-1'
