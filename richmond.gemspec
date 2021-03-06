# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'richmond/version'

Gem::Specification.new do |spec|
  spec.name          = "richmond"
  spec.version       = Richmond::VERSION
  spec.authors       = ["crmckenzie"]
  spec.email         = ["crmckenzie@gmail.com"]
  spec.summary       = %q{scrape files for content and emit an aggregate file}
  spec.homepage      = "http://github.com/crmckenzie/richmond"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'autotest'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-autotest"
  spec.add_development_dependency "pry"

end
