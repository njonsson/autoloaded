module Autoloaded; end

# Translates source filenames into constants.
  #
  # @since 1.3
#
# @api private
module Autoloaded::Inflection

  # Translates a _String_ representing a source filename into a _Symbol_
  # representing a constant.
  #
  # @param [String] source_filename the name of a source code file
  #
  # @return [Symbol] the name of a constant corresponding to _source_filename_
  #
  # @raise [ArgumentError] _source_filename_ is +nil+ or empty
  #
  # @note Directories are ignored rather than translated into namespaces.
  def self.to_constant_name(source_filename)
    source_filename = source_filename.to_s
    raise(::ArgumentError, "can't be blank") if source_filename.empty?

    translate(source_filename, *%i(file_basename
                                   camelize_if_lowercase
                                   nonalphanumeric_to_underscore
                                   delete_leading_nonalphabetic
                                   capitalize_first)).to_sym
  end

private

  def self.camelize(string)
    string.gsub(/(.)(?:_|-)+(.)/) do |match|
      "#{match[0..0].downcase}#{match[-1..-1].upcase}"
    end
  end

  def self.camelize_if_lowercase(string)
    return string unless lowercase?(string)

    camelize string
  end

  def self.capitalize_first(string)
    "#{string[0..0].upcase}#{string[1..-1]}"
  end

  def self.delete_leading_nonalphabetic(string)
    string.gsub(/^[^a-z]+/i, '')
  end

  def self.file_basename(string)
    ::File.basename string, ::File.extname(string)
  end

  def self.lowercase?(string)
    string == string.downcase
  end

  def self.nonalphanumeric_to_underscore(string)
    string.gsub(/[^a-z0-9]+/i, '_')
  end

  def self.translate(string, *translations)
    translations.inject string do |result, translation|
      send translation, result
    end
  end

end
