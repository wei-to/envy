require 'envy'

namespace :envy do
  namespace :vars do
    desc 'Upload current variables'
    task :upload do |t|
      Envy.upload_vars
    end

    desc 'Download latest variables'
    task :download do |t|
      Envy.download_vars
    end

    desc 'Load current variables to ENV'
    task :load do |t|
      Envy.load_vars
    end
  end
end