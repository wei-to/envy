if defined?(Rails)
  module Envy
    class Railtie < Rails::Railtie
      config.before_configuration do
#        Envy.get
      end
    end
  end
end