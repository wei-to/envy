require 'envy'

if defined?(Rails)
  module Envy
    class Railtie < Rails::Railtie
      config.before_configuration do
        Envy.load_vars
      end
      rake_tasks do
        require 'envy/tasks'
      end    
    end
  end
end