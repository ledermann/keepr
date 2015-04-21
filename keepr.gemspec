# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keepr/version'

Gem::Specification.new do |spec|
  spec.name          = "keepr"
  spec.version       = Keepr::VERSION
  spec.authors       = 'Georg Ledermann'
  spec.email         = 'mail@georg-ledermann.de'
  spec.description   = %q{Double entry bookkeeping with Rails}
  spec.summary       = %q{Some basic ActiveRecord models to build a double entry bookkeeping application}
  spec.homepage      = 'https://github.com/ledermann/keepr'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4.1'
  spec.add_dependency 'ancestry'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'coveralls'
end
