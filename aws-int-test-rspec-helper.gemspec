require 'rake'

Gem::Specification.new do |s|
  s.name          = 'aws-int-test-rspec-helper'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.authors       = %w(someguy)
  s.summary       = 'aws-int-test-rspec-helper'
  s.description   = 'RSpec helper to make integration testing in AWS a small bit more convenient'
  s.files         = FileList[ 'lib/*.rb' ]

  s.add_runtime_dependency('aws-sdk', '2.2.17')
  s.add_runtime_dependency('cfndsl', '0.4.0')
  s.add_runtime_dependency('rspec', '3.4.0')
end