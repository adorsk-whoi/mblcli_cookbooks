packages = value_for_platform(
  "default" => %w{lua5.1 liblua5.1-0-dev liblua50-dev liblualib50-dev}
)
packages.each do |pkg|
  package pkg do
    action :upgrade
  end
end