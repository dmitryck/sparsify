# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sparsify/version'

Gem::Specification.new do |spec|
  spec.name          = 'sparsify'
  spec.version       = Sparsify::VERSION
  spec.authors       = ['Ryan Biesemeyer']
  spec.email         = ['ryan@simplymeasured.com']
  spec.description   = 'Flattens deeply-nested hashes into sparse hashes'
  spec.summary       = 'Flattens deeply-nested hashes into sparse hashes'
  spec.homepage      = 'https://www.github.com/simplymeasured/sparsify'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'ruby-appraiser-rubocop'
end
