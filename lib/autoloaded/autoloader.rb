module Autoloaded

  # Autoloads files in a source directory.
  #
  # @since 1.3
  class Autoloader

    # The source code context in which autoloading is to occur.
    #
    # @return [Binding]
    #
    # @see #autoload!
    #
    # @api private
    attr_reader :host_binding

    # Constructs a new _Autoloader_ with the specified _host_binding_.
    #
    # @param [Binding] host_binding a value for _#host_binding_
    #
    # @raise [ArgumentError] _host_binding_ is +nil+
    #
    # @api private
    def initialize(host_binding)
      raise(::ArgumentError, "can't be nil") if host_binding.nil?

      @host_binding = host_binding
      @specifications = Specifications.new
    end

    # Issues +autoload+ statements for source files found in _#from_. The
    # constants are renamed by _#with_ and _#only_. The source files are filtered
    # by _#except_ and _#only_.
    #
    # @return [Array of Array] the arguments passed to each +autoload+ statement
    #                          made
    #
    # @see http://ruby-doc.org/core/Module.html#method-i-autoload Module#autoload
    # @see http://ruby-doc.org/core/Kernel.html#method-i-autoload Kernel#autoload
    # @see #from
    # @see #except
    # @see #only
    # @see #with
    #
    # @api private
    def autoload!
      result = []
      from_load_pathed_directory.each_source_filename do |source_filename|
        source_basename = ::File.basename(source_filename)
        next if specifications.except.any? { |spec| spec.match source_basename }

        unless specifications.only.empty? ||
               specifications.only.any? { |spec| spec.match source_basename }
          next
        end

        first_match = (specifications.with + specifications.only).inject(nil) do |match, spec|
          match || spec.match(source_basename)
        end
        constant_names = Array(first_match ||
                               Inflection.to_constant_name(source_basename))
        existing_source_filenames = constant_names.collect do |const|
          existing_autoload? const
        end
        if existing_source_filenames.all? { |file| file == source_filename }
          next
        end

        existing_source_filenames.zip(constant_names).each do |file, const|
          if file
            Warning.changing_autoload constant_name:        constant_full_name(const),
                                      old_source_filename:  file,
                                      new_source_filename:  source_filename,
                                      host_source_location: host_source_location
          end
        end

        if existing_source_filenames.compact.empty?
          constant_names.each do |const|
            next unless existing_constant?(const)

            Warning.existing_constant constant_name:        constant_full_name(const),
                                      source_filename:      source_filename,
                                      host_source_location: host_source_location
          end
        end

        constant_names.each do |const|
          establish_autoload const, source_filename
          result << [const, source_filename]
        end
      end
      result
    end

    # @!method except(*arguments)
    #   Specifies constants and/or source files not to be autoloaded. _Symbol_
    #   arguments signify the names of constants and _String_ arguments signify
    #   the names of source files. You can specify _#except_ multiple times, and
    #   its effects are cumulative.
    #
    #   Source file names specified are relative to _#from_.
    #
    #   Valid arguments include:
    #
    #   * _Symbol_ values
    #   * _String_ values
    #   * _Array_ values comprising _Symbol_ and/or _String_ values
    #   * _Hash_ values comprising _Symbol_, _String_, and/or _Array_ values
    #     described above
    #   * Any combination of the options described above
    #
    #   @return [Autoloader] the _Autoloader_
    #
    #   @raise [RuntimeError] _#only_ already has a specification
    #
    #   @see #autoload!
    #   @see #from
    #   @see #only
    #
    # @!method only(*arguments)
    #   Specifies constants and/or source files to be autoloaded exclusively.
    #   _Symbol_ arguments signify the names of constants and _String_ arguments
    #   signify the names of source files. You can specify _#only_ multiple
    #   times, and its effects are cumulative.
    #
    #   Source file names specified are relative to _#from_.
    #
    #   Valid arguments include:
    #
    #   * _Symbol_ values
    #   * _String_ values
    #   * _Array_ values comprising _Symbol_ and/or _String_ values
    #   * _Hash_ values comprising _Symbol_, _String_, and/or _Array_ values
    #     described above, which will autoload specified constants from their
    #     associated source files
    #   * Any combination of the options described above
    #
    #   @return [Autoloader] the _Autoloader_
    #
    #   @raise [RuntimeError] _#except_ already has a specification
    #
    #   @see #autoload!
    #   @see #from
    #   @see #except
    #
    # @!method with(*arguments)
    #   Specifies constants and/or source files to be autoloaded whose names may
    #   have unpredictable spellings, stylization, or organization. _Symbol_
    #   arguments signify the names of constants and _String_ arguments signify
    #   the names of source files. You can specify _#with_ multiple times, and
    #   its effects are cumulative.
    #
    #   Source file names specified are relative to _#from_.
    #
    #   Valid arguments include:
    #
    #   * _Symbol_ values
    #   * _Array_ values comprising _Symbol_ values
    #   * _Hash_ values comprising _Symbol_, _String_, and/or _Array_ values
    #     described above, which will autoload specified constants from their
    #     associated source files
    #   * Any combination of the options described above
    #
    #   @return [Autoloader] the _Autoloader_
    #
    #   @see #autoload!
    #   @see #from
    [:except, :only, :with].each do |attr|
      define_method attr do |*arguments|
        attr_specs = specifications.send(attr)
        if arguments.empty?
          return attr_specs.collect(&:value)
        end

        attr_specs << Specification.new(*arguments)
        begin
          specifications.validate! attr
        rescue
          attr_specs.pop
          raise
        end

        self
      end
    end

    # The directory from which source files are autoloaded.
    #
    # Defaults to the directory corresponding to the +__FILE__+ of
    # _#host_binding_. For example, if <code>eval('__FILE__',
    # host_binding)</code> evaluates to +'/absolute/path/to/my_awesome_gem.rb'+,
    # then the default value of _#from_ is +'/absolute/path/to/my_awesome_gem'+.
    #
    # @param [String] value a source directory path; optional
    #
    # @return [String] if _value_ is +nil+, the source directory
    # @return [Autoloader] if _value_ is not +nil+, the _Autoloader_
    #
    # @raise [ArgumentError] _value_ is a relative path
    #
    # @see #autoload!
    # @see #host_binding
    def from(value=nil)
      return((@from && @from.path) || default_from) if value.nil?

      # Validate value.
      @from = LoadPathedDirectory.new(value)

      self
    end

  private

    attr_reader :specifications

    def constant_full_name(constant_name)
      "#{host_eval 'name rescue nil'}::#{constant_name}"
    end

    def default_from
      filename = host_source_filename
      dirname  = ::File.dirname(filename)
      basename = ::File.basename(filename, ::File.extname(filename))
      ::File.join dirname, basename
    end

    def establish_autoload(constant_name, source_filename)
      host_eval "autoload #{constant_name.to_sym.inspect}, #{source_filename.inspect}"
    end

    def existing_autoload?(constant_name)
      host_eval "autoload? #{constant_name.to_sym.inspect}"
    end

    def existing_constant?(constant_name)
      host_eval "constants.include? #{constant_name.to_sym.inspect}"
    end

    def from_load_pathed_directory
      @from || LoadPathedDirectory.new(default_from)
    end

    def host_eval(statement)
      # TODO: Why does adding the third and fourth arguments break Kernel#eval ?
      # ::Kernel.eval statement, host_binding, __FILE__, __LINE__
      ::Kernel.eval statement, host_binding
    end

    def host_source_filename
      host_eval '::File.expand_path __FILE__'
    end

    def host_source_location
      host_eval('[__FILE__, __LINE__]').collect(&:to_s).join ':'
    end

  end

end
