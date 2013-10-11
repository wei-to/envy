# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'envy/version'

Gem::Specification.new do |spec|
  spec.name          = 'envy'
  spec.version       = Envy::VERSION
  spec.authors       = ['David Bird', 'Juergen Busam']
  spec.email         = ['dave@wei.to', 'juergen@wei.to']
  spec.summary       = %q{Sharing environment variables.}
  spec.description   = %q{Sharing environment variables between users.}  
  spec.homepage      = 'https://github.com/wei-to/envy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fog', '>= 1.3.1'
  spec.add_dependency 'hashie'
  spec.add_development_dependency 'bundler', '~> 1.3'  
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.13.0'
end
