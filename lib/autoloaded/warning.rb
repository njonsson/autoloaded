module Autoloaded; end

# Prints warning messages to _stderr_.
#
# @since 1.3
#
# @api private
module Autoloaded::Warning

  class << self

    # Sets the warning stream.
    #
    # @param [IO] value a new value for #io
    attr_writer :io

    # The warning stream. Defaults to +$stderr+.
    #
    # @return [IO] the warning stream
    def io
      @io || $stderr
    end

    # Prints a warning message to _#io_ concerning an existing autoloaded
    # constant for which the autoloaded source file is being changed.
    #
    # @param [Symbol] constant_name        the name of the constant
    # @param [String] old_source_filename  the name of the existing autoloaded
    #                                      source file
    # @param [String] new_source_filename  the name of the new autoloaded source
    #                                      file
    # @param [String] host_source_location the file and line number of the source
    #                                      establishing autoloading
    #
    # @return [Module] _Warning_
    #
    # @raise [ArgumentError] one or more keywords are missing
    def changing_autoload(constant_name:        raise(::ArgumentError,
                                                      'missing keyword: constant_name'),
                          old_source_filename:  raise(::ArgumentError,
                                                      'missing keyword: old_source_filename'),
                          new_source_filename:  raise(::ArgumentError,
                                                      'missing keyword: new_source_filename'),
                          host_source_location: raise(::ArgumentError,
                                                      'missing keyword: host_source_location'))
      message = "Existing autoload of \e[4m#{constant_name}\e[0m from "       +
                "#{old_source_filename.inspect} is being overridden to "      +
                "autoload from #{new_source_filename.inspect} -- avoid this " +
                "warning by using an \e[4monly\e[0m or an \e[4mexcept\e[0m "  +
                "specification in the block at #{host_source_location}"
      warn message
    end

    # Enables or disables warning messages depending on the specified _enabling_
    # argument.
    #
    # @param [Object] enabling disables warnings if +nil+ or +false+
    #
    # @yield if a block is given, the value of _#enabled?_ is reset after the
    #        block is called
    #
    # @return if a block is given, the result of calling the block
    # @return [Module] if a block is not given, _Warning_
    #
    # @see .enabled?
    def enable(enabling)
      previous_value = @disabled
      @disabled = not!(enabling)
      if block_given?
        begin
          return yield
        ensure
          @disabled = previous_value
        end
      end

      self
    end

    # Indicates whether warning messages are enabled or disabled.
    #
    # @return [true] if warning messages are enabled
    # @return [false] if warning messages are enabled
    #
    # @see .enable
    def enabled?
      not! @disabled
    end

    # Prints a warning message to _#io_ concerning a defined constant for which
    # autoloading is being established.
    #
    # @param [Symbol] constant_name        the name of the constant
    # @param [String] source_filename      the name of the autoloaded source file
    # @param [String] host_source_location the file and line number of the source
    #                                      establishing autoloading
    #
    # @return [Module] _Warning_
    #
    # @raise [ArgumentError] one or more keywords are missing
    def existing_constant(constant_name:        raise(::ArgumentError,
                                                      'missing keyword: constant_name'),
                          source_filename:      raise(::ArgumentError,
                                                      'missing keyword: source_filename'),
                          host_source_location: raise(::ArgumentError,
                                                      'missing keyword: host_source_location'))
      message = "Existing definition of \e[4m#{constant_name}\e[0m obviates " +
                "autoloading from #{source_filename.inspect} -- avoid this "  +
                "warning by using an \e[4monly\e[0m or an \e[4mexcept\e[0m "  +
                "specification in the block at #{host_source_location}"
      warn message
    end

  private

    def not!(value)
      value.nil? || (value == false)
    end

    def warn(message)
      warning = "\e[33m*** \e[7m WARNING \e[0m #{message}"
      io.puts(warning) if enabled?

      self
    end

  end

end
