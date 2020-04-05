# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'autoloaded/version'

Gem::Specification.new do |spec|
  spec.name        = 'autoloaded'
  spec.version     = Autoloaded::VERSION
  spec.authors     = ['Nils Jonsson']
  spec.email       = ['autoloaded@nilsjonsson.com']

  spec.summary     = <<-end_summary.chomp.gsub(/^\s+/, '').gsub("\n", ' ')
                       Eliminates the drudgery of handcrafting a Ruby Core
                       library `autoload` statement for each Ruby source code
                       file in your project. It also avoids the limitations of
                       rigid convention-driven facilities such as those provided
                       by the ActiveSupport RubyGem.
                     end_summary
  spec.description = <<-end_description.chomp.gsub(/^\s+/, '').gsub("\n", ' ')
                       If you like the ‘Module#autoload’ feature of the Ruby Core
                       library, you may have wished for Autoloaded. It eliminates
                       the drudgery of handcrafting an `autoload` statement for
                       each Ruby source code file in your project. It also avoids
                       the limitations of rigid convention-driven facilities such
                       as those provided by the ActiveSupport RubyGem. Autoloaded
                       assumes, but does not enforce, `CamelCase`-to-`snake_case`
                       correspondence between the names of constants and source
                       files. You can combine conventions, even putting multiple
                       autoloaded constants in a single source file.
                     end_description
  spec.homepage    = 'https://njonsson.github.io/autoloaded'
  spec.license     = 'MIT'

  spec.required_ruby_version = '~> 2'

  spec.add_development_dependency 'codeclimate-test-reporter', '~>  0'
  if RUBY_VERSION < '2.2'
    spec.add_development_dependency 'rake',                    '~> 12'
  else
    spec.add_development_dependency 'rake',                    '~> 13'
  end
  spec.add_development_dependency 'rspec',                     '~>  3.3'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
                         f.match(%r{^(test|spec|features)/})
                       end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename f }
  spec.require_paths = %w(lib)
end
