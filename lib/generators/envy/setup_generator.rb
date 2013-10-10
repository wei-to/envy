module Envy
  module Generators
    class SetupGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_yaml
        copy_file 'envy.yml', 'config/envy.yml'
      end

      def configure_gitignore
        append_file('.gitignore', '/config/envy.yml') if File.exists?('.gitignore')
      end
    end
  end
end