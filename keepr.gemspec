# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keepr/version'

Gem::Specification.new do |spec|
  spec.name          = 'keepr'
  spec.version       = Keepr::VERSION
  spec.authors       = 'Georg Ledermann'
  spec.email         = 'mail@georg-ledermann.de'
  spec.description   = 'Double entry bookkeeping with Rails'
  spec.summary       = 'Some basic ActiveRecord models to build a double entry bookkeeping application'
  spec.homepage      = 'https://github.com/ledermann/keepr'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.4'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4.2'
  spec.add_dependency 'ancestry'
  spec.add_dependency 'datev', '>= 0.5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
