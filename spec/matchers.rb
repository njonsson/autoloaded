RSpec::Matchers.define :autoload_a_constant_named do |constant_name|
  match do |source_file|
    # Ensure the file exists.
    File.read source_file

    constant_tokens = constant_name.split('::')
    constant_up_till_last = constant_tokens[0...-1].join('::')
    constant_last = constant_tokens.last
    pid = fork do
      begin
        eval constant_name
      rescue
      else
        raise("Constant #{constant_name} is already defined")
      end

      load source_file

      begin
        eval constant_name
      rescue
        exit 1
      end
      unless eval(constant_up_till_last).autoload?(constant_last.to_sym)
        exit 1
      end
    end
    Process.wait pid
    $?.success?
  end
end

RSpec::Matchers.define :define_only_constants_named do |*constant_names|
  attr_reader :expected_constants, :extraneous_defined_constants, :namespace_name

  match do |source_file|
    # Ensure the file exists.
    File.read source_file

    unless namespace_name
      raise "Missing .in_a_namespace_named(:Namespace) clause"
    end

    reader, writer = IO.pipe
    pid = fork do
      reader.close

      load source_file

      begin
        constant_names.each do |constant_name|
          eval(namespace_name).const_get constant_name
        end
        eval(namespace_name).constants.each do |constant_name|
          writer.puts constant_name.inspect
        end
      rescue
      end
    end
    Process.wait pid
    writer.close
    if $?.success?
      defined_constants = []
      reader.each_line do |line|
        binding.pry
        defined_constants << eval(line.chomp)
      end
      defined_constants = defined_constants.sort.collect(&:to_sym)
      @expected_constants = constant_names.sort.collect(&:to_sym)
      @extraneous_defined_constants = defined_constants - expected_constants
      extraneous_defined_constants.empty?
    else
      false
    end
  end

  chain :in_a_namespace_named do |namespace_name|
    @namespace_name = namespace_name
  end

  failure_message do |source_file|
    "expected only #{expected_constants.join ' and '} to be defined in #{namespace_name} but also found #{extraneous_defined_constants.join ' and '}"
  end
end
