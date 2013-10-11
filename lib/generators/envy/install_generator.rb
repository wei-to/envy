module Envy
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_yaml
        copy_file 'envy.yml', 'config/envy.yml'
        copy_file 'fog.yml', 'config/fog.yml'
      end

      def configure_gitignore
        append_file('.gitignore', "/config/envy.yml\n/config/fog.yml") if File.exists?('.gitignore')
      end
    end
  end
end