require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'envy'
require 'rspec'
require 'rspec/autorun'

RSpec.configure do |config|
  config.color_enabled = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end