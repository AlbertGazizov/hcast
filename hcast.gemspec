# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hcast/version'

Gem::Specification.new do |spec|
  spec.name          = "hcast"
  spec.version       = HCast::VERSION
  spec.authors       = ["Albert Gazizov"]
  spec.email         = ["deeper4k@gmail.com"]
  spec.description   = %q{Hash Caster and Validator}
  spec.summary       = %q{Hash Caster and Validator}
  spec.homepage      = "http://github.com/AlbertGazizov/hcast"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "rake"
end
