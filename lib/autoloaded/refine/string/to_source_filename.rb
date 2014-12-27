require 'autoloaded/compatibility/refine_and_using'

module Autoloaded

  module Refine

    module String; end

  end

end

# Refines _String_ to translate a constant name into a source filename.
#
# @since 0.0.1
#
# @api private
module Autoloaded::Refine::String::ToSourceFilename

  # @!method to_source_filename
  #   Translates the name of a constant into the name of a source file.
  #
  #   @return [String] the name of a source file corresponding to the name of a
  #                    constant
  #
  #   @note Namespaces are ignored rather than translated into directories.
  refine ::String do
    def replace_nonalphanumeric_sequence_with_separator
      gsub(/[^a-z0-9]+/i, separator.to_s)
    end

    def separate_capital_and_following_capitalized_word
      gsub(/([A-Z])([A-Z])([a-z])/,
           "\\1#{separator}\\2\\3")
    end

    def separate_digit_and_following_letter
      gsub(/([0-9])([a-z])/i, "\\1#{separator}\\2")
    end

    def separate_lowercase_letter_and_following_capital_letter
      gsub(/([a-z])([A-Z])/, "\\1#{separator}\\2")
    end

    def separator
      '_'
    end

    def to_source_filename
      replace_nonalphanumeric_sequence_with_separator.
        separate_capital_and_following_capitalized_word.
        separate_lowercase_letter_and_following_capital_letter.
        separate_digit_and_following_letter.
        downcase
    end
  end

end
