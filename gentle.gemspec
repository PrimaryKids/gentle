# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gentle/version'

Gem::Specification.new do |spec|
  spec.name          = "gentle"
  spec.version       = Gentle::VERSION
  spec.authors       = ["DynamoMTL"]
  spec.email         = [""]
  spec.description   = "API Client for Quiet Logistics Services"
  spec.summary       = "Integrates with QL Blackboard and work Queue"
  spec.homepage      = "http://github.com/DynamoMTL/qls"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('aws-sdk', '~> 3')
  spec.add_dependency('nokogiri')
  spec.add_dependency('activesupport')

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5.0.0"
  spec.add_development_dependency "mocha"
end
