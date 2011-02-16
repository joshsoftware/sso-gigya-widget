config_file = File.join(Rails.root, 'config', 'config.yml')

if File.exist?( config_file )
  ApplicationConfig = YAML.load_file( config_file )[RAILS_ENV]
else
  raise "No configuration file found at the following address: " + config_file
end

