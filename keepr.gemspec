# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keepr/version'

Gem::Specification.new do |spec|
  spec.name          = "keepr"
  spec.version       = Keepr::VERSION
  spec.authors       = ['Georg Ledermann']
  spec.email         = ['mail@georg-ledermann.de']
  spec.description   = %q{Double entry bookkeeping with Ruby}
  spec.summary       = %q{Some basic models to build a double entry bookkeeping application}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 3.1'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec'
end
