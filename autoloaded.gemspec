# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'autoloaded/version'

Gem::Specification.new do |spec|
  spec.name          = 'autoloaded'
  spec.version       = Autoloaded::VERSION
  spec.authors       = ['Nils Jonsson']
  spec.email         = ['autoloaded@nilsjonsson.com']
  spec.summary       = <<-end_summary.gsub(/^\s+/, '').gsub("\n", ' ')
                         Dynamically and flexibly loads source files in a
                         directory when a corresponding constant is dereferenced.
                       end_summary
  spec.description   = spec.summary +
                       ' '          +
                       <<-end_description.gsub(/^\s+/, '').gsub(/\n(?=\S)/, ' ').chomp
                         Offers several advantages over other autoloading
                         facilities such as those provided by the Ruby Core
                         library and the ActiveSupport gem: (a) it does not
                         require a separate `autoload` statement for each
                         constant, and (b) it does not enforce CamelCase to
                         snake_case correspondence between the names of constants
                         and source files.
                       end_description
  spec.homepage      = 'https://github.com/njonsson/autoloaded'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename f }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2'

  spec.add_development_dependency 'bundler', '~>  1'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~>  3'
end
