# Holds regulations for autoloading.
#
# @since 1.3
#
# @api private
class Autoloaded::Specifications

  # @!method except
  #   _Specifications_ for excluding source files from being autoloaded.
  #
  #   @return [Array of Specification]
  #
  #   @see Specification
  #
  #   @api private
  #
  # @!method only
  #   _Specifications_ for narrowing the set of source files being autoloaded as
  #   well as optionally renaming and/or reorganizing their corresponding
  #   constants.
  #
  #   @return [Array of Specification]
  #
  #   @see Specification
  #
  #   @api private
  #
  # @!method with
  #   _Specifications_ for renaming and/or reorganizing the constants corresponding
  #   to source files being autoloaded.
  #
  #   @return [Array of Specification]
  #
  #   @see Specification
  #
  #   @api private
  %i(except only with).each do |attribute_name|
    define_method attribute_name do
      variable_name = "@#{attribute_name}"
      (instance_variable_get(variable_name) || []).tap do |value|
        instance_variable_set variable_name, value
      end
    end
  end

  # Evaluates the specifications for conflicts, in reference to the specified
  # _attribute_.
  #
  # @param [Symbol] attribute the attribute (+:except+, +:only+, or +:with+)
  #                           being modified
  #
  # @return [Specifications] the _Specifications_
  #
  # @raise [RuntimeError] _attribute_ is +:except+ and _#only_ is not empty
  # @raise [RuntimeError] _attribute_ is +:only+ and _#except_ is not empty
  #
  # @see #except
  # @see #only
  def validate!(attribute)
    other_attribute = {except: :only, only: :except}[attribute]
    if other_attribute
      unless send(attribute).empty? || send(other_attribute).empty?
        raise "can't specify `#{attribute}' when `#{other_attribute}' is " +
              'already specified'
      end
    end

    self
  end
end
