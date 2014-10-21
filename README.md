# Autoloaded

_Autoloaded_ dynamically and flexibly loads source files in a directory when a
corresponding constant is dereferenced. It offers several advantages over other
autoloading facilities such as those provided by the
[Ruby Core library](http://ruby-doc.org/core/Module.html#method-i-autoload) and
the
[ActiveSupport](http://api.rubyonrails.org/classes/ActiveSupport/Autoload.html)
gem:

* It does not require a separate `autoload` statement for each constant
* It does not enforce `CamelCase` to `snake_case` correspondence between the
  names of constants and source files

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'autoloaded', '~> 0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autoloaded

## Usage

TODO: Write usage instructions here

## Contributing

1. [Fork the official repository](https://github.com/njonsson/autoloaded/fork).
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. Create a [new pull request](https://github.com/njonsson/autoloaded/compare).
