module Autoloaded; end

# Prints deprecation messages to _stderr_.
#
# @since 1.3
#
# @api private
module Autoloaded::Deprecation

  class << self

    # Sets the deprecation stream.
    #
    # @param [IO] value a new value for #io
    attr_writer :io

    # The deprecation stream. Defaults to +$stderr+.
    #
    # @return [IO] the deprecation stream
    def io
      @io || $stderr
    end

    # Prints a deprecation message to _#io_ regarding the specified
    # _deprecated_usage_.
    #
    # @param [String] deprecated_usage API usage that is soon to be discontinued
    # @param [String] sanctioned_usage API usage that will succeed
    #                                  _deprecated_usage_
    # @param [String] source_filename  the file path of the source invoking the
    #                                  deprecated API
    #
    # @return [Module] _Deprecation_
    #
    # @raise [ArgumentError] one or more keywords are missing
    def deprecate(deprecated_usage: raise(::ArgumentError,
                                          'missing keyword: deprecated_usage'),
                  sanctioned_usage: raise(::ArgumentError,
                                          'missing keyword: sanctioned_usage'),
                  source_filename:  raise(::ArgumentError,
                                          'missing keyword: source_filename'))
      deprecation = "\e[33m*** \e[7m DEPRECATED \e[0m "     +
                    "\e[4m#{deprecated_usage}\e[0m -- use " +
                    "\e[4m#{sanctioned_usage}\e[0m instead in #{source_filename}"
      io.puts deprecation

      self
    end

  end

end
