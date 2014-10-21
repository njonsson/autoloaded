source 'https://rubygems.org'

gemspec

group :debug do
  gem   'pry-byebug',   '~> 2',                 platforms: [:mri_20, :mri_21]
  gem   'pry-debugger', '~> 0',                 platforms: :mri_19
end

group :tooling do
  gem   'guard-rspec',  '~> 4', require: false
  if RUBY_PLATFORM =~ /darwin/i
    gem 'rb-fsevent',   '~> 0', require: false
  end
end
