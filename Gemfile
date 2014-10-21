source 'https://rubygems.org'

gemspec

group :tooling do
  gem   'guard-rspec',  '~> 4', require: false
  if RUBY_PLATFORM =~ /darwin/i
    gem 'rb-fsevent',   '~> 0', require: false
  end
end
