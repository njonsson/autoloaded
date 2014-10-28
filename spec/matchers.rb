require 'support/without_side_effects'

RSpec::Matchers.define :autoload_a_constant_named do |constant_name|
  match do |source_file|
    # Ensure the file exists.
    File.open source_file, 'r' do
    end

    constant_tokens = constant_name.split('::')
    constant_up_till_last = constant_tokens[0...-1].join('::')
    constant_last = constant_tokens.last

    without_side_effects do
      begin
        eval constant_name.to_s
      rescue NameError
      else
        raise("#{constant_name} is already defined")
      end

      load source_file

      begin
        eval constant_name.to_s
      rescue NameError
        false
      else
        eval(constant_up_till_last).autoload? constant_last.to_sym
      end
    end
  end
end

RSpec::Matchers.define :define_only_constants_named do |*constant_names|
  attr_reader :expected_constants, :extraneous_defined_constants, :namespace_name

  match do |source_file|
    @expected_constants, @extraneous_defined_constants = [], []

    # Ensure the file exists.
    File.open source_file, 'r' do
    end

    unless namespace_name
      raise "missing .in_a_namespace_named(:Namespace) clause"
    end

    defined_constants = without_side_effects do
      load source_file

      namespace = eval(namespace_name.to_s)

      # Trigger autoloading.
      constant_names.each do |constant_name|
        namespace.const_get constant_name
      end

      namespace.constants.sort.collect(&:to_sym)
    end
    @expected_constants = constant_names.sort.collect(&:to_sym)
    @extraneous_defined_constants = defined_constants - expected_constants
    extraneous_defined_constants.empty?
  end

  chain :in_a_namespace_named do |namespace_name|
    @namespace_name = namespace_name
  end

  failure_message do |source_file|
    "expected only #{expected_constants.join ' and '} to be defined in #{namespace_name} but also found #{extraneous_defined_constants.join ' and '}"
  end
end
