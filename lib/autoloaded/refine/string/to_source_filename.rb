module Autoloaded

  module Refine

    module String; end

  end

end

module Autoloaded::Refine::String::ToSourceFilename

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
