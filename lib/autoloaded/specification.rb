require 'autoloaded'

module Autoloaded

  # Describes regulations for autoloading.
  #
  # @since 1.3
  #
  # @api private
  class Specification

    # The elements of the specification.
    #
    # @return [Array]
    attr_reader :elements

    # Constructs a new _Specification_ with the specified _elements_.
    #
    # @param elements the value of _#elements_
    #
    # Valid arguments include:
    #
    # * _Symbol_ values
    # * _Array_ values comprising _Symbol_ values
    # * _Hash_ values comprising _Symbol_, _String_, and/or _Array_ values
    #   described above, which will autoload specified constants from their
    #   associated source files
    # * Any combination of the options described above
    #
    # @see #elements
    def initialize(*elements)
      @elements = elements
    end

    # Compares the _Specification_ with the specified _other_object_.
    #
    # @param other_object another object
    #
    # @return [true] if _other_object_ is equal to the _Specification_
    # @return [false] if _other_object_ is not equal to the _Specification_
    def ==(other_object)
      return false unless other_object.kind_of?(self.class)

      other_object.elements == elements
    end

    # Provides a matching constant from _#elements_ for the specified
    # _source_filename_.
    #
    # @param [String] source_filename the name of a source file
    #
    # @return [Symbol] a matching constant
    # @return [Array of Symbol] matching constants
    # @return [nil] if there is no matching constant
    #
    # @see #elements
    def match(source_filename)
      matched = elements.detect do |element|
        if element.kind_of?(::Hash)
          element.each do |key, value|
            return value if source_filename_match?(source_filename, key)

            return key if source_filename_match?(source_filename, value)
          end
          false
        else
          source_filename_match? source_filename, element
        end
      end

      matched.kind_of?(::String) ? Inflection.to_constant_name(matched) : matched
    end

  private

    def source_filename_match?(file, array_or_file_or_constant)
      case array_or_file_or_constant
        when ::Array
          array_or_file_or_constant.detect do |o|
            source_filename_match? file, o
          end
        when ::Symbol
          source_filename_match_constant_name? file, array_or_file_or_constant
        else
          source_filename_match_filename? file, array_or_file_or_constant
      end
    end

    def source_filename_match_constant_name?(file, constant)
      Inflection.to_constant_name(file).to_s.casecmp(constant.to_s).zero?
    end

    def source_filename_match_filename?(file1, file2)
      file1.to_s.casecmp(file2.to_s).zero?
    end

  end

end
