#
# Cookbook Name:: whenever
# Attributes:: whenever
#

default[:whenever][:configs_dir] = "/data/whenever_jobs"

default[:whenever][:jobs] = {}

default[:whenever][:defaults][:at] = ""
default[:whenever][:defaults][:every] = "day"
default[:whenever][:defaults][:user] = "root"
default[:whenever][:defaults][:command] = ""

