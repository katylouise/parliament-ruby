# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parliament/version'

Gem::Specification.new do |spec|
  spec.name          = 'parliament-ruby'
  spec.version       = Parliament::VERSION
  spec.authors       = ['Matt Rayner', 'Rebecca Appleyard', 'Giuseppe De Santis']
  spec.email         = ['mattrayner1@gmail.com', 'rklappleyard@gmail.com']
  spec.summary       = %q{Internal parliamentary API wrapper}
  spec.description   = %q{Internal parliamentary data API wrapper for ruby}
  spec.homepage      = 'http://github.com/ukparliament/parliament_ruby'
  spec.license       = 'Nonstandard'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'typhoeus', '~> 1.3'

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.51'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'i18n', '~> 0.8'
  spec.add_development_dependency 'parliament-grom-decorators', '~> 0.1'
end
