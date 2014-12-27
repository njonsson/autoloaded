# Eliminates the drudgery of handcrafting a Ruby Core library +autoload+
# statement for each Ruby source code file in your project.
#
# @since 0.0.1
module Autoloaded

  autoload :Autoloader,          'autoloaded/autoloader'
  autoload :Constant,            'autoloaded/constant'
  autoload :Deprecation,         'autoloaded/deprecation'
  autoload :Inflection,          'autoloaded/inflection'
  autoload :LoadPathedDirectory, 'autoloaded/load_pathed_directory'
  autoload :Refine,              'autoloaded/refine'
  autoload :Specification,       'autoloaded/specification'
  autoload :Specifications,      'autoloaded/specifications'
  autoload :VERSION,             'autoloaded/version'
  autoload :Warning,             'autoloaded/warning'

  def self.extended(other_module)
    caller_file_path = caller_locations.first.absolute_path
    Deprecation.deprecate deprecated_usage: "extend #{name}",
                          sanctioned_usage: "#{name}.module { }",
                          source_filename:  caller_file_path
    dir_path = "#{::File.dirname caller_file_path}/#{::File.basename caller_file_path, '.rb'}"
    other_module.module_eval <<-end_module_eval, __FILE__, __LINE__
      def self.autoload?(symbol)
        if (old_school = super)
          return old_school
        end

        require 'autoloaded/constant'
        filenames = []
        ::Autoloaded::Constant.new(symbol).each_matching_filename_in #{dir_path.inspect} do |filename|
          filenames << filename
        end
        (filenames.length <= 1) ? filenames.first : filenames
      end

      def self.const_missing(symbol)
        require 'autoloaded/constant'
        ::Autoloaded::Constant.new(symbol).each_matching_filename_in #{dir_path.inspect} do |filename|
          require filename
          if const_defined?(symbol)
            begin
              return const_get(symbol)
            rescue ::NameError
            end
          end
        end

        super
      end
    end_module_eval
  end

  # @!method self.module
  #   Autoloads constants that match files in the source directory.
  #
  #   @yield [Autoloader] accepts options for regulating autoloading
  #
  #   @return [Array of Array] the arguments passed to each +autoload+ statement
  #                            made
  #
  #   @raise [LocalJumpError] no block is given
  #
  #   @since 1.3
  #
  #   @example Autoloading a namespace
  #     # lib/my_awesome_gem/db.rb
  #
  #     module MyAwesomeGem
  #
  #       Autoloaded.module { }
  #
  #     end
  #
  #   @example Autoloading with optional specifications
  #     # lib/my_awesome_gem/db.rb
  #
  #     module MyAwesomeGem
  #
  #       class DB
  #
  #         results = Autoloaded.class do |autoloaded|
  #           autoloaded.with   :MySQL, :PostgreSQL, [:Access, :SQLServer] => 'MicroSoft'
  #           autoloaded.except 'SELF-DESTRUCT!'
  #         end
  #         STDOUT.puts results.inspect  # See output below.
  #
  #       end
  #
  #     end
  #
  #     # [[:Access,     'my_awesome_gem/db/MicroSoft'  ],
  #     #  [:SQLServer,  'my_awesome_gem/db/MicroSoft'  ],
  #     #  [:MySQL,      'my_awesome_gem/db/mysql'      ],
  #     #  [:Oracle,     'my_awesome_gem/db/oracle'     ],
  #     #  [:PostgreSQL, 'my_awesome_gem/db/postgre_sql']]
  def self.module(&block)
    raise(::LocalJumpError, 'no block given (yield)') unless block

    yield(autoloader = Autoloader.new(block.binding))
    autoloader.autoload!
  end

  # Enables or disables warning messages depending on the specified _enabling_
  # argument.
  #
  # @param [Object] enabling disables warnings if +nil+ or +false+
  #
  # @yield if a block is given, the value of _#warn?_ is reset after the block is
  #        called
  #
  # @return if a block is given, the result of calling the block
  # @return [Autoloaded] if a block is not given, _Autoloaded_ (_Module_)
  #
  # @since 1.3
  #
  # @see .warn?
  def self.warn(enabling, &block)
    result = Warning.enable(enabling, &block)

    block ? result : self
  end

  # Indicates whether warning messages are enabled or disabled.
  #
  # @return [true] if warning messages are enabled
  # @return [false] if warning messages are disabled
  #
  # @since 1.3
  #
  # @see .warn
  def self.warn?
    Warning.enabled?
  end

  class << self

    alias_method :class, :module

  end

end
