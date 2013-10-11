require 'envy/railtie'
require 'envy/version'
require 'hashie'
require 'yaml'

module Envy
  
  extend self
  
  def environment
    defined?(Rails) ? Rails.env.to_s : 'development'
  end
  
  def fog_file
    defined?(Rails) ? Rails.root.join('config/fog.yml') : nil
  end

  def vars_file
    defined?(Rails) ? Rails.root.join('config/envy.yml') : nil
  end
  
  def vars_yaml
    File.exist?(vars_file) ? YAML.load(File.read(vars_file)) : {}
  end
  
  def global_vars
    vars_yaml.reject{|key, value| value.kind_of?(Hash)}
  end  
  
  def environment_vars
    vars_yaml.fetch(environment, {})
  end
  
  def vars 
    global_vars.merge(environment_vars)
  end
  
  def load_vars
    vars.each{|key, value| ENV[key.to_s] = value.to_s unless ENV.key?(key.to_s)}
  end
  
  def fog_credentials
    if File.exist?(fog_file) 
      credentials = File.read(fog_file)
      begin
        YAML.load(credentials)
      rescue Exception => e
        raise Envy::ConfigurationError, 'Malformed configuration in envy.yml.'
      end
    else
      {}
    end
  end
  
  def fog_root
    if !Envy.fog_credentials || Envy.fog_credentials.empty?
      raise Envy::ConfigurationError, 'No fog configuration detected.'
    else
      credentials = Hashie::Mash.new(Envy.fog_credentials)
      begin
        connection = Fog::Storage.new(credentials.fog_credentials)
      rescue ArgumentError => e
        raise Envy::ConfigurationError, e.message
      end
      root = connection.directories.get(credentials.fog_directory) 
      root = connection.directories.create(key: credentials.fog_directory, public: true) if root.nil?
      root
    end
  end
    
  def upload_vars
    root = fog_root
    current_version = root.files.size
    new_version = current_version += 1
    key = "#{'%05d' % new_version}-#{Time.now.strftime('%Y%m%d%H%M')}.yml"
    file = root.files.create(
      key: key,
      body: File.read(vars_file)
    )
    file
  end
  
  def download_vars
    fog_root.files.last
  end
  
  class ConfigurationError < StandardError; end
    
end
