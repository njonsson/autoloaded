require 'open3'

RSpec::Matchers.define :autoload_a_constant_named do |constant_name|
  match do |source_file|
    # Ensure the file exists.
    File.read source_file

    constant_tokens = constant_name.split('::')
    constant_up_till_last = constant_tokens[0...-1].join('::')
    constant_last = constant_tokens.last
    assertion = <<-end_assertion.gsub(/^      /, '')
      begin;
        #{constant_name};
      rescue;
      else;
        raise('Constant #{constant_name} is already defined');
      end;

      load #{source_file.inspect};

      puts(begin;
             #{constant_name};
           rescue;
             'false';
           else;
             #{constant_up_till_last}.autoload?(:#{constant_last}) ?
               'true'                                              :
               'false';
           end)
    end_assertion
    quoted_assertion = assertion.chomp.inspect.gsub('\n', "\n")
    Open3.popen3 "bundle exec ruby -e #{quoted_assertion}" do |stdin,
                                                               stdout,
                                                               stderr|
      if (stderr_output = stderr.read.chomp).empty?
        eval stdout.read.chomp
      else
        raise stderr_output
      end
    end
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

    assertion = <<-end_assertion.gsub(/^      /, '')
      load #{source_file.inspect};

      puts(begin;
             #{constant_names.inspect}.each do |constant_name|
               #{namespace_name}.const_get constant_name;
             end;
             #{namespace_name}.constants.inspect;
           rescue;
             '[]';
           end)
    end_assertion
    quoted_assertion = assertion.chomp.inspect.gsub('\n', "\n")
    Open3.popen3 "bundle exec ruby -e #{quoted_assertion}" do |stdin,
                                                               stdout,
                                                               stderr|
      if (stderr_output = stderr.read.chomp).empty?
        defined_constants = Array(eval(stdout.read.chomp)).sort.collect(&:to_sym)
        @expected_constants = constant_names.sort.collect(&:to_sym)
        @extraneous_defined_constants = defined_constants - expected_constants
        extraneous_defined_constants.empty?
      else
        raise stderr_output
      end
    end
  end

  chain :in_a_namespace_named do |namespace_name|
    @namespace_name = namespace_name
  end

  failure_message do |source_file|
    "expected only #{expected_constants.join ' and '} to be defined in #{namespace_name} but also found #{extraneous_defined_constants.join ' and '}"
  end
end
