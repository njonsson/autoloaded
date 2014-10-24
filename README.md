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

Suppose you have the following source files:

* lib/
  * my_awesome_gem/
    * db/
      * mysql.rb
      * postgresql.rb
      * sql_server.rb
    * db.rb
  * my_awesome_gem.rb

The following statements establish autoloading — one statement per namespace:

```ruby
# lib/my_awesome_gem.rb
module MyAwesomeGem

  extend Autoloaded

end

# lib/my_awesome_gem/db.rb
module MyAwesomeGem

  module DB

    extend Autoloaded

  end

end
```

Note that your preferred casing of constants is accommodated automatically:

```ruby
MyAwesomeGem::DB::MySQL.new
MyAwesomeGem::DB::PostgreSQL.new
MyAwesomeGem::DB::SQLServer.new
```

_Autoloaded_ does not perform deep autoloading of nested namespaces and
directories. This is by design.

### Important note

You must extend a namespace with _Autoloaded_ **from within the file in which the
namespace is defined**. This is because _Autoloaded_ utilizes the source file
path of the namespace to establish which directory will be autoloaded. That path
is discoverable only via the stack trace of `extend Autoloaded`.

In the following example, autoloading of the _MyAwesomeGem_ namespace will not
occur because the name of the source file in which the `extend` statement is
invoked does not match the name of the namespace.

```ruby
# lib/my_awesome_gem.rb
module MyAwesomeGem; end

# lib/my_awesome_gem/db.rb
module MyAwesomeGem

  # WRONG! Autoloading will not occur.
  extend Autoloaded

  module DB

    extend Autoloaded

  end

end
```

## Contributing

1. [Fork the official repository](https://github.com/njonsson/autoloaded/fork).
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. Create a [new pull request](https://github.com/njonsson/autoloaded/compare).
