# coding: utf-8
#
# When used to extend a module, the _Autoloaded_ module dynamically loads
# constants into that module from source files contained in its filesystem path.
#
# @note You must extend a namespace with _Autoloaded_ from within the file in
#   which the namespace is defined. This is because _Autoloaded_ utilizes the
#   source file path of the namespace to establish which directory will be
#   autoloaded. That path is discoverable only via the stack trace of `extend
#   Autoloaded`.
#
# Suppose you have the following source files:
#
# * lib/
#   * my_awesome_gem/
#     * db/
#       * mysql.rb
#       * postgresql.rb
#       * sql_server.rb
#     * db.rb
#   * my_awesome_gem.rb
#
# The following statements establish autoloading — one statement per namespace:
#
#   # lib/my_awesome_gem.rb
#   module MyAwesomeGem
#
#     extend Autoloaded
#
#   end
#
#   # lib/my_awesome_gem/db.rb
#   module MyAwesomeGem
#
#     module DB
#
#       extend Autoloaded
#
#     end
#
#   end
#
# Note that your preferred casing of constants is accommodated automatically.
#
#   # Unlike Kernel#autoload and Module#autoload, Autoloaded is not clairvoyant about
#   # what constants will be autoloaded.
#   MyAwesomeGem::DB.constants  # => []
#
#   # But like Kernel#autoload and Module#autoload, Autoloaded does tell you which
#   # source files will be autoloaded. (The difference is that it may return an array
#   # of potential matches instead of just one filename.)
#   MyAwesomeGem::DB.autoload? :MySQL        # => 'db/mysql'
#   MyAwesomeGem::DB.autoload? :PostgreSQL   # => 'db/postgresql'
#   MyAwesomeGem::DB.autoload? :SQLServer    # => 'db/sql_server'
#   MyAwesomeGem::DB.autoload? :Nonexistent  # => nil
#
#   MyAwesomeGem::DB::MySQL
#   MyAwesomeGem::DB.constants    # => [:MySQL]
#   MyAwesomeGem::DB::PostgreSQL
#   MyAwesomeGem::DB.constants    # => [:MySQL, :PostgreSQL]
#   MyAwesomeGem::DB::SQLServer
#   MyAwesomeGem::DB.constants    # => [:MySQL, :PostgreSQL, :SQLServer]
#
# _Autoloaded_ does not perform deep autoloading of nested namespaces and
# directories. This is by design.
#
# In the following example, autoloading of the _MyAwesomeGem_ namespace will not occur because the name of the source file in which the `extend` statement is invoked does not match the name of the namespace.
#
#   # lib/my_awesome_gem.rb
#   module MyAwesomeGem; end
#
#   # lib/my_awesome_gem/db.rb
#   module MyAwesomeGem
#
#     # WRONG!
#     extend Autoloaded
#
#     module DB
#
#       extend Autoloaded
#
#     end
#
#   end
#
#   # some_other_file.rb
#   require 'my_awesome_gem'
#   MyAwesomeGem::DB  # NameError is raised!
#
module Autoloaded

  def self.extended(other_module)
    caller_file_path = caller_locations.first.absolute_path
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

end

Dir.glob "#{File.dirname __FILE__}/#{File.basename __FILE__, '.rb'}/*.rb" do |f|
  require_relative "#{File.basename __FILE__, '.rb'}/#{File.basename f, '.rb'}"
end
