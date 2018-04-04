# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sanford-protocol/version'

Gem::Specification.new do |gem|
  gem.name          = "sanford-protocol"
  gem.version       = Sanford::Protocol::GEM_VERSION
  gem.authors       = ["Collin Redding", "Kelly Redding"]
  gem.email         = ["collin.redding@me.com", "kelly@kellyredding.com"]
  gem.summary       = "Ruby implementation of the Sanford TCP communication protocol."
  gem.description   = "Ruby implementation of the Sanford TCP communication protocol."
  gem.homepage      = "https://github.com/redding/sanford-protocol"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.16.3"])

  gem.add_dependency("bson", ["~> 1.7", "< 1.10.0"])

end
