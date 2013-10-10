require 'envy/railtie'
require 'envy/version'
require 'yaml'

module Envy
  
  extend self
  
  def environment
    defined?(Rails) ? Rails.env.to_s : 'development'
  end

  def file
    defined?(Rails) ? Rails.root.join('config/envy.yml') : nil
  end
  
  def yaml
    File.exist?(file) ? YAML.load(File.read(file)) : {}
  end
  
  def global_vars
    yaml.reject{|key, value| value.kind_of?(Hash)}
  end  
  
  def environment_vars
    yaml.fetch(environment, {})
  end
  
  def vars 
    global_vars.merge(environment_vars)
  end
  
  def load_vars
    vars.each{|key, value| ENV[key.to_s] = value.to_s unless ENV.key?(key.to_s)}
  end
  
  def get
  end
  
end
