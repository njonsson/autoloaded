[![Autoloaded graphic]][spider-gear-image]

# Autoloaded

[![Travis CI build status]      ][Travis-CI-build-status]
[![Code Climate quality report] ][Code-Climate-report]
[![Code Climate coverage report]][Code-Climate-report]
[![Gemnasium build status]      ][Gemnasium-build-status]
[![Inch CI build status]        ][Inch-CI-build-status]
[![RubyGems release]            ][RubyGems-release]

_Autoloaded_ dynamically and flexibly loads source files in a directory when a
corresponding constant is dereferenced. It offers several advantages over other
autoloading facilities such as those provided by the
[Ruby Core library][Ruby-Core-Module-autoload] and the
[ActiveSupport][ActiveSupport-Autoload] gem:

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

Note that your preferred casing of constants is accommodated automatically.

```ruby
# Unlike Kernel#autoload and Module#autoload, Autoloaded is not clairvoyant about
# what constants will be autoloaded.
MyAwesomeGem::DB.constants  # => []

# But like Kernel#autoload and Module#autoload, Autoloaded does tell you which
# source files will be autoloaded. (The difference is that it may return an array
# of potential matches instead of just one filename.)
MyAwesomeGem::DB.autoload? :MySQL        # => 'db/mysql'
MyAwesomeGem::DB.autoload? :PostgreSQL   # => 'db/postgresql'
MyAwesomeGem::DB.autoload? :SQLServer    # => 'db/sql_server'
MyAwesomeGem::DB.autoload? :Nonexistent  # => nil

MyAwesomeGem::DB::MySQL
MyAwesomeGem::DB.constants    # => [:MySQL]
MyAwesomeGem::DB::PostgreSQL
MyAwesomeGem::DB.constants    # => [:MySQL, :PostgreSQL]
MyAwesomeGem::DB::SQLServer
MyAwesomeGem::DB.constants    # => [:MySQL, :PostgreSQL, :SQLServer]
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

  # WRONG!
  extend Autoloaded

  module DB

    extend Autoloaded

  end

end

# some_other_file.rb
require 'my_awesome_gem'
MyAwesomeGem::DB  # NameError is raised!
```

## Contributing

1. [Fork][fork-Autoloaded] the official repository.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. [Create][compare-Autoloaded-branches] a new pull request.

## License

Released under the [MIT License][MIT-License].

[Autoloaded graphic]:           https://farm5.staticflickr.com/4134/4941065976_54737fe145.jpg
[Travis CI build status]:       https://secure.travis-ci.org/njonsson/autoloaded.svg?branch=master
[Code Climate quality report]:  https://codeclimate.com/github/njonsson/autoloaded/badges/gpa.svg
[Code Climate coverage report]: https://codeclimate.com/github/njonsson/autoloaded/badges/coverage.svg
[Gemnasium build status]:       https://gemnasium.com/njonsson/autoloaded.svg
[Inch CI build status]:         http://inch-ci.org/github/njonsson/autoloaded.svg?branch=master
[RubyGems release]:             https://badge.fury.io/rb/autoloaded.svg

[spider-gear-image]:           https://www.flickr.com/photos/dongkwan/4941065976              "spider gear image by Ernesto Andrade"
[Travis-CI-build-status]:      http://travis-ci.org/njonsson/autoloaded                       "Travis CI build status for Autoloaded"
[Code-Climate-report]:         http://codeclimate.com/github/njonsson/autoloaded              "Code Climate report for Autoloaded"
[Gemnasium-build-status]:      http://gemnasium.com/njonsson/autoloaded                       "Gemnasium build status for Autoloaded"
[Inch-CI-build-status]:        http://inch-ci.org/github/njonsson/autoloaded                  "Inch CI build status for Autoloaded"
[RubyGems-release]:            http://rubygems.org/gems/autoloaded                            "RubyGems release of Autoloaded"
[Ruby-Core-Module-autoload]:   http://ruby-doc.org/core/Module.html#method-i-autoload         "‘Module#autoload’ method in the Ruby Core Library"
[ActiveSupport-Autoload]:      http://api.rubyonrails.org/classes/ActiveSupport/Autoload.html "‘ActiveSupport::Autoload’ module in the Rails API"
[fork-Autoloaded]:             https://github.com/njonsson/autoloaded/fork                    "Fork the official repository of Autoloaded"
[compare-Autoloaded-branches]: https://github.com/njonsson/autoloaded/compare                 "Compare branches of Autoloaded repositories"
[MIT-License]:                 http://github.com/njonsson/autoloaded/blob/master/License.md   "MIT License claim for Autoloaded"
