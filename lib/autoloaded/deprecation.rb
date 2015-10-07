require 'autoloaded'

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
    # @param [Hash] keywords the parameters of the deprecation message
    # @option keywords [String] :deprecated_usage API usage that is soon to be
    #                                             discontinued
    # @option keywords [String] :sanctioned_usage API usage that will succeed
    #                                             _:deprecated_usage_
    # @option keywords [String] :source_filename  the file path of the source
    #                                             invoking the deprecated API
    #
    # @return [Module] _Deprecation_
    #
    # @raise [ArgumentError] one or more keywords are missing
    def deprecate(keywords)
      deprecated_usage = fetch(keywords, :deprecated_usage)
      sanctioned_usage = fetch(keywords, :sanctioned_usage)
      source_filename  = fetch(keywords, :source_filename)

      deprecation = "\e[33m*** \e[7m DEPRECATED \e[0m "     +
                    "\e[4m#{deprecated_usage}\e[0m -- use " +
                    "\e[4m#{sanctioned_usage}\e[0m instead in #{source_filename}"
      io.puts deprecation

      self
    end

  private

    def fetch(keywords, keyword)
      keywords.fetch keyword do
        raise ::ArgumentError, "missing keyword: #{keyword}"
      end
    end

  end

end
