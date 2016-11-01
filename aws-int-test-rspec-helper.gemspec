require 'rake'

Gem::Specification.new do |s|
  s.name          = 'aws-int-test-rspec-helper'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.authors       = %w(someguy)
  s.summary       = 'aws-int-test-rspec-helper'
  s.description   = 'RSpec helper to make integration testing in AWS a small bit more convenient'
  s.files         = FileList[ 'lib/*.rb' ]
  s.homepage      = 'https://github.com/stelligent/aws-int-test-rspec-helper'
  s.required_ruby_version = '>= 2.1.0'

  s.add_runtime_dependency('aws-sdk', '2.6.14')
  s.add_runtime_dependency('cfndsl', '0.4.0')
  s.add_runtime_dependency('rspec', '3.4.0')
end