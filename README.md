[![Autoloaded graphic]][spider-gear-image]

# Autoloaded

[![Travis CI build status]      ][Travis-CI-build-status]
[![Code Climate quality report] ][Code-Climate-report]
[![Code Climate coverage report]][Code-Climate-report]

[![Gemnasium build status]      ][Gemnasium-build-status]
[![Inch CI build status]        ][Inch-CI-build-status]
[![RubyGems release]            ][RubyGems-release]

If you like the [_Module#autoload_][Ruby-Core-Module-autoload] feature of the
Ruby Core library, you may have wished for _Autoloaded_. It eliminates the
drudgery of handcrafting an `autoload` statement for each Ruby source code file
in your project. It also avoids the limitations of rigid convention-driven
facilities such as those provided by the [ActiveSupport][ActiveSupport-Autoload]
RubyGem.

_Autoloaded_ assumes, but does not enforce, `CamelCase`-to-`snake_case`
correspondence between the names of constants and source files. You can combine
conventions, even putting multiple autoloaded constants in a single source file.

## Installation

Install [the RubyGem][RubyGems-release].

    $ gem install autoloaded

Use _Autoloaded_ in your RubyGem project by making it a runtime dependency.

```ruby
# my_awesome_gem.gemspec

Gem::Specification.new do |spec|
  # ...
  spec.add_dependency 'autoloaded', '~> 1'
  # ...
end
```

Or you may want to make _Autoloaded_ a dependency of your project by using
[Bundler][Bundler].

```ruby
# Gemfile

source 'http://rubygems.org'

gem 'autoloaded', '~> 1'
```

## Usage

Suppose you have the following source files.

    lib/
    ├─ my_awesome_gem/
    │  ├─ db/
    │  │  ├─ MicroSoft.rb
    │  │  ├─ SELF-DESTRUCT!.rb
    │  │  ├─ mysql.rb
    │  │  ├─ oracle.rb
    │  │  └─ postgre_sql.rb
    │  ├─ db.rb
    │  └─ version.rb
    └─ my_awesome_gem.rb

### The _Autoloaded.module_ or _Autoloaded.class_ method

The _Autoloaded.module_ and _Autoloaded.class_ method calls below invoke
[_Module#autoload_][Ruby-Core-Module-autoload] for each source file in the
calling module’s corresponding directory. Note that these methods must receive a
block, even if it’s an empty block.

The file paths used are abbreviated, if possible, using a directory of the Ruby
load path (`$:`). They are also rendered without their _.rb_ extension.

```ruby
# lib/my_awesome_gem.rb
module MyAwesomeGem

  Autoloaded.module { }

  # The above is the equivalent of:
  #
  # autoload :Db,      'my_awesome_gem/db'
  # autoload :Version, 'my_awesome_gem/version'

end

# lib/my_awesome_gem/db.rb
module MyAwesomeGem

  class DB

    # The 'class' and 'module' methods are aliases -- use either one.
    Autoloaded.class { }

    # The above is the equivalent of:
    #
    # autoload :MicroSoft,      'my_awesome_gem/db/MicroSoft'
    # autoload :SELF_DESTRUCT_, 'my_awesome_gem/db/SELF-DESTRUCT!'
    # autoload :Mysql,          'my_awesome_gem/db/mysql'
    # autoload :Oracle,         'my_awesome_gem/db/oracle'
    # autoload :PostgreSql,     'my_awesome_gem/db/postgre_sql'

  end

end
```

The code above is succinct, but it’s not exactly correct. The constants
`MyAwesomeGem::DB`, `MyAwesomeGem::DB::MySQL`, and others are not set up to
autoload properly because they are misspelled (case-sensitively speaking).

```ruby
MyAwesomeGem.autoload?          :DB  # => nil
MyAwesomeGem.const_defined?     :DB  # => false
MyAwesomeGem.constants.include? :DB  # => false

MyAwesomeGem::DB  # Raises NameError because lib/my_awesome_gem/db.rb does not
                  # get autoloaded!

MyAwesomeGem.autoload?          :Db  # => 'my_awesome_gem/db' (a lie!)
MyAwesomeGem.const_defined?     :Db  # => true (a lie!)
MyAwesomeGem.constants.include? :Db  # => true (a lie!)

MyAwesomeGem::Db  # Raises NameError because lib/my_awesome_gem/db.rb defines
                  # MyAwesomeGem::DB, not MyAwesomeGem::Db!

#################################################################################

require 'my_awesome_gem/db'

MyAwesomeGem::DB.autoload?          :MySQL  # => nil
MyAwesomeGem::DB.const_defined?     :MySQL  # => false
MyAwesomeGem::DB.constants.include? :MySQL  # => false

MyAwesomeGem::DB::MySQL  # Raises NameError because
                         # lib/my_awesome_gem/db/mysql.rb does not get
                         # autoloaded!

MyAwesomeGem::DB.autoload?          :Mysql  # => 'my_awesome_gem/db/mysql' (a lie!)
MyAwesomeGem::DB.const_defined?     :Mysql  # => true (a lie!)
MyAwesomeGem::DB.constants.include? :Mysql  # => true (a lie!)

MyAwesomeGem::DB::Mysql  # Raises NameError because
                         # lib/my_awesome_gem/db/mysql.rb defines
                         # MyAwesomeGem::DB::MySQL, not MyAwesomeGem::DB::Mysql!
```

### The `with` specification

_Autoloaded_ needs hints from you concerning unpredictable spellings,
stylization, and organization of constant names and/or source file names. You can
specify `with` as:

* A symbol or array of symbols representing constants to autoload
* A hash of symbols and strings representing constants and the source filename(s)
  from which to autoload them
* A combination of the above

A symbol provided to `with` signifies the name of a constant, and a string
signifies the name of a source file.

Specifying `with` does not filter the source files; it maps the source files to
different constants, or tweaks the names of constants.

You can specify `with` multiple times, and its effects are cumulative.

```ruby
# lib/my_awesome_gem.rb
module MyAwesomeGem

  Autoloaded.module do |autoloaded|
    autoloaded.with :DB, :VERSION
    # Or:
    # autoloaded.with :DB
    # autoloaded.with :VERSION
    # Or:
    # autoloaded.with DB: 'db', VERSION: 'version'
    # Or:
    # autoloaded.with DB:      'db'
    # autoloaded.with VERSION: 'version'
    # Or:
    # autoloaded.with 'db' => :DB, 'version' => :VERSION
    # Or:
    # autoloaded.with 'db'      => :DB
    # autoloaded.with 'version' => :VERSION
  end

  # The above is the equivalent of:
  #
  # autoload :DB,      'my_awesome_gem/db'
  # autoload :VERSION, 'my_awesome_gem/version'

end

# lib/my_awesome_gem/db.rb
module MyAwesomeGem

  class DB

    Autoloaded.class do |autoloaded|
      autoloaded.with :MySQL, :PostgreSQL, [:Access, :SQLServer] => 'MicroSoft'
      # Or:
      # autoloaded.with :MySQL,
      #                 :PostgreSQL,
      #                 Access:    'MicroSoft',
      #                 SQLServer: 'MicroSoft'
      # Or:
      # autoloaded.with :MySQL, :PostgreSQL, 'MicroSoft' => [:Access, :SQLServer]
      # Or:
      # autoloaded.with :MySQL,
      #                 :PostgreSQL,
      #                 'MicroSoft' => :Access,
      #                 'MicroSoft' => :SQLServer
      # Or ...
    end

    # The above is the equivalent of:
    #
    # autoload :Access,         'my_awesome_gem/db/MicroSoft'
    # autoload :SQLServer,      'my_awesome_gem/db/MicroSoft'
    # autoload :SELF_DESTRUCT_, 'my_awesome_gem/db/SELF-DESTRUCT!'
    # autoload :MySQL,          'my_awesome_gem/db/mysql'
    # autoload :Oracle,         'my_awesome_gem/db/oracle'
    # autoload :PostgreSQL,     'my_awesome_gem/db/postgre_sql'

  end

end
```

Now you’re autoloading all the constants you want to be autoloading.

```ruby
MyAwesomeGem.autoload?          :DB  # => 'my_awesome_gem/db'
MyAwesomeGem.const_defined?     :DB  # => true
MyAwesomeGem.constants.include? :DB  # => true

MyAwesomeGem::DB  # => MyAwesomeGem::DB

MyAwesomeGem.autoload?          :Db  # => nil
MyAwesomeGem.const_defined?     :Db  # => false
MyAwesomeGem.constants.include? :Db  # => false

MyAwesomeGem::Db  # Raises NameError as expected.

#################################################################################

MyAwesomeGem::DB.autoload?          :MySQL  # => 'my_awesome_gem/db/mysql'
MyAwesomeGem::DB.const_defined?     :MySQL  # => true
MyAwesomeGem::DB.constants.include? :MySQL  # => true

MyAwesomeGem::DB::MySQL  # => MyAwesomeGem::DB::MySQL

MyAwesomeGem::DB.autoload?          :Mysql  # => nil
MyAwesomeGem::DB.const_defined?     :Mysql  # => false
MyAwesomeGem::DB.constants.include? :Mysql  # => false

MyAwesomeGem::DB::Mysql  # Raises NameError as expected.
```

### The `except` and `only` specifications

What about source files you **don’t** want to be autoloaded?

```ruby
MyAwesomeGem::DB::SELF_DESTRUCT_  # Loading this file does something bad, so
                                  # let's not.
```

If you really want to avoid loading *lib/my_awesome_gem/db/SELF-DESTRUCT!.rb*, so
much so that you don’t want an `autoload` statement made for it, specify
`except`.

```ruby
# lib/my_awesome_gem/db.rb

module MyAwesomeGem

  class DB

    Autoloaded.class do |autoloaded|
      autoloaded.with :MySQL, :PostgreSQL, [:Access, :SQLServer] => 'MicroSoft'

      autoloaded.except 'SELF-DESTRUCT!'
      # Or:
      # autoloaded.except :SELF_DESTRUCT_
      # Or ...
    end

    # The above is the equivalent of:
    #
    # autoload :Access,     'my_awesome_gem/db/MicroSoft'
    # autoload :SQLServer,  'my_awesome_gem/db/MicroSoft'
    # autoload :MySQL,      'my_awesome_gem/db/mysql'
    # autoload :Oracle,     'my_awesome_gem/db/oracle'
    # autoload :PostgreSQL, 'my_awesome_gem/db/postgre_sql'

  end

end
```

```ruby
MyAwesomeGem::DB.autoload?          :SELF_DESTRUCT_  # => nil
MyAwesomeGem::DB.const_defined?     :SELF_DESTRUCT_  # => false
MyAwesomeGem::DB.constants.include? :SELF_DESTRUCT_  # => false

MyAwesomeGem::DB::SELF_DESTRUCT_  # Raises NameError as expected.
```

You can specify `except` as:

* A symbol or array of symbols representing constants to avoid autoloading
* A string or array of strings representing source filenames to avoid autoloading
* A hash of symbols and/or strings representing constants and/or source filenames
  to avoid autoloading
* A combination of the above

The `only` specification is like `except` but it has the opposite effect, namely,
that **only** specified constants and/or source files will be autoloaded.

You can specify `only` as:

* A symbol or array of symbols representing constants to autoload
* A string or array of strings representing source filenames to autoload
* A hash of symbols and/or strings representing constants and the source
  filename(s) from which to autoload them
* A combination of the above

A symbol provided to `except` or `only` signifies the name of a constant, and a
string signifies the name of a source file.

You can specify `except` and `only` multiple times, and their effects are
cumulative.

### The `from` specification

It’s recommended that you call _Autoloaded.module_ or _Autoloaded.class_ from
within the source file where your module or class is defined. This practice
allows _Autoloaded_ to assume that the source files to be autoloaded are in a
directory of the same name (and in the same location) as the module’s defining
source file.

There are circumstances, however, in which you cannot rely on the computed
directory for autoloading. Perhaps the directory has a different name from the
module’s defining source file. Or perhaps you are autoloading a library that you
didn’t author. In these situations you can specify `from` with the path from
which source files should be autoloaded.

```ruby
# somewhere_else.rb

module MyAwesomeGem

  Autoloaded.module do |autoloaded|
    # The following code is not actually very useful since the installed location
    # of a RubyGem varies with the operating system and user preferences. How to
    # compute the path properly is outside the scope of this readme and is left
    # as an exercise for the reader.
    autoloaded.from '/absolute/path/to/my_awesome_gem'
  end

end
```

A path provided to `from` cannot be relative; it must start with the filesystem
root.

If you specify `from` multiple times in an _Autoloaded_ block, only the last one
takes effect.

### The _Autoloaded.warn_ method

There are two circumstances under which _Autoloaded_ by default will write
warnings to stderr:

* Overriding an established autoload
* Establishing an autoload for a defined constant

You can silence these warnings by passing `false` to _Autoloaded.warn_.  (Passing
`true` turns warnings on if they are off.)

```ruby
# lib/my_awesome_gem/db.rb

module MyAwesomeGem

  class DB

    Autoloaded.warn false  # Turn off Autoloaded warnings.

    autoload :SQLServer, 'my_awesome_gem/db/MicroSoft'

    class Oracle; end

    Autoloaded.class { }  # This duplicates the 'autoload' statement and class
                          # definition above, but no Autoloaded warnings will be
                          # displayed.

    Autoloaded.warn true  # Turn on Autoloaded warnings again.

  end

end
```

Use the block form if you want to ensure warnings get toggled on or off for a
series of statements.

```ruby
# lib/my_awesome_gem/db.rb

module MyAwesomeGem

  class DB

    autoload :SQLServer, 'my_awesome_gem/db/MicroSoft'

    class Oracle; end

    Autoloaded.warn false do
      Autoloaded.class { }  # This duplicates the 'autoload' statement and class
                            # definition above, but no Autoloaded warnings will
                            # be displayed.
    end

    # Autoloaded warnings are turned on again automatically.

  end

end
```

### How to debug autoloading

The _Autoloaded.module_ or _Autoloaded.class_ method returns an ordered list of
arguments it has passed to `autoload`.

```ruby
# lib/my_awesome_gem/db.rb

module MyAwesomeGem

  class DB

    results = Autoloaded.class do |autoloaded|
      autoloaded.with   :MySQL, :PostgreSQL, [:Access, :SQLServer] => 'MicroSoft'
      autoloaded.except 'SELF-DESTRUCT!'
    end
    STDOUT.puts results.inspect  # See output below.

  end

end

# [[:Access,     'my_awesome_gem/db/MicroSoft'  ],
#  [:SQLServer,  'my_awesome_gem/db/MicroSoft'  ],
#  [:MySQL,      'my_awesome_gem/db/mysql'      ],
#  [:Oracle,     'my_awesome_gem/db/oracle'     ],
#  [:PostgreSQL, 'my_awesome_gem/db/postgre_sql']]
```

You can also hook [_Module#autoload_][Ruby-Core-Module-autoload] and
[_Kernel#autoload_][Ruby-Core-Kernel-autoload] via monkeypatching or other means
in order to see what’s happening.

### Source filenames are relative to the `from` specification

You may have noticed that source filenames in the above examples are not
absolute. They are relative to the _Autoloaded_ block’s `from` specification
(which I recommend that you allow to be computed for you —
[see above](#the-from-specification)).

### Recursive autoloading not supported

_Autoloaded_ does not perform deep autoloading of nested namespaces and
directories. This is by design.

## Contributing

1. [Fork][fork-Autoloaded] the official repository.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. [Create][compare-Autoloaded-branches] a new pull request.

Development
-----------

After cloning the repository, `bin/setup` to install dependencies. Then `rake` to
run the tests. You can also `bin/console` to get an interactive prompt that will
allow you to experiment.

To install this gem onto your local machine, `bundle exec rake install`. To
release a new version, update the version number in _lib/autoloaded/version.rb_,
and then `bundle exec rake release`, which will create a Git tag for the version,
push Git commits and tags, and push the _.gem_ file to
[RubyGems.org](RubyGems-release).

## License

Released under the [MIT License][MIT-License].

[Autoloaded graphic]:           https://farm5.staticflickr.com/4134/4941065976_54737fe145.jpg
[Travis CI build status]:       https://secure.travis-ci.org/njonsson/autoloaded.svg?branch=v1.x
[Code Climate quality report]:  https://codeclimate.com/github/njonsson/autoloaded/badges/gpa.svg
[Code Climate coverage report]: https://codeclimate.com/github/njonsson/autoloaded/badges/coverage.svg
[Gemnasium build status]:       https://gemnasium.com/njonsson/autoloaded.svg
[Inch CI build status]:         http://inch-ci.org/github/njonsson/autoloaded.svg?branch=v1.x
[RubyGems release]:             https://badge.fury.io/rb/autoloaded.svg

[spider-gear-image]:           https://www.flickr.com/photos/dongkwan/4941065976              "spider gear image by Ernesto Andrade"
[Travis-CI-build-status]:      http://travis-ci.org/njonsson/autoloaded                       "Travis CI build status for Autoloaded"
[Code-Climate-report]:         http://codeclimate.com/github/njonsson/autoloaded              "Code Climate report for Autoloaded"
[Gemnasium-build-status]:      http://gemnasium.com/njonsson/autoloaded                       "Gemnasium build status for Autoloaded"
[Inch-CI-build-status]:        http://inch-ci.org/github/njonsson/autoloaded                  "Inch CI build status for Autoloaded"
[RubyGems-release]:            http://rubygems.org/gems/autoloaded                            "RubyGems release of Autoloaded"
[Ruby-Core-Module-autoload]:   http://ruby-doc.org/core/Module.html#method-i-autoload         "‘Module#autoload’ method in the Ruby Core Library"
[ActiveSupport-Autoload]:      http://api.rubyonrails.org/classes/ActiveSupport/Autoload.html "‘ActiveSupport::Autoload’ module in the Rails API"
[Bundler]:                     http://bundler.io
[Ruby-Core-Kernel-autoload]:   http://ruby-doc.org/core/Kernel.html#method-i-autoload         "‘Kernel#autoload’ method in the Ruby Core Library"
[fork-Autoloaded]:             https://github.com/njonsson/autoloaded/fork                    "Fork the official repository of Autoloaded"
[compare-Autoloaded-branches]: https://github.com/njonsson/autoloaded/compare                 "Compare branches of Autoloaded repositories"
[MIT-License]:                 http://github.com/njonsson/autoloaded/blob/master/License.md   "MIT License claim for Autoloaded"
