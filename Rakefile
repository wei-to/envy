require 'rubygems'
require 'bundler'
Bundler.setup

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
desc 'Run all specs.'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec