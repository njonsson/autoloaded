require 'support/util'
require 'support/without_side_effects'

RSpec::Matchers.define :define_constants do |*constant_names|
  match do |source_file|
    # Ensure the file exists.
    File.open source_file, 'r' do
    end

    without_side_effects do
      constant_names.each do |constant_name|
        if Util.constantize(constant_name)
          fail "constant #{constant_name} is already defined outside #{source_file}"
        end
      end

      load source_file

      any_statically_defined = false
      if dynamically?
        any_statically_defined = constant_names.any? do |constant_name|
          current_scope = Object
          constant_name.split(Util.namespace_delimiter).all? do |token|
            current_scope.constants.include?(token.to_sym).tap do |result|
              if result
                current_scope = Util.constantize([current_scope.name, token].join(Util.namespace_delimiter))
              end
            end
          end
        end
      end

      if any_statically_defined
        false
      else
        constant_names.all? do |constant_name|
          namespace, unqualified_constant_name = Util.namespace_and_unqualified_constant_name(constant_name,
                                                                                              raise_if_namespace_invalid: true)
          (!dynamically? ||
           !namespace.constants.include?(unqualified_constant_name.to_sym)) &&
            Util.constantize(constant_name)
        end
      end
    end
  end

  chain :dynamically do
    @dynamically = true
  end

  description do
    fragments = []
    fragments << case constant_names.length
                   when 0
                     'no constants'
                   when 1
                     "constant #{constant_names.first}"
                   else
                     "constants #{constant_names.join ' and '}"
                 end
    fragments << 'dynamically' if dynamically?
    "define #{fragments.join ' '}"
  end

  def dynamically?
    @dynamically
  end
end

RSpec::Matchers.define :set_up_autoload_for_constant do |constant_name|
  match do |source_file|
    # Ensure the file exists.
    File.open source_file, 'r' do
    end

    without_side_effects do
      namespace, unqualified_constant_name = Util.namespace_and_unqualified_constant_name(constant_name)
      if namespace && namespace.autoload?(unqualified_constant_name)
        fail "#{namespace.name}::#{unqualified_constant_name} is already set up for autoload outside #{source_file}"
      end

      load source_file

      namespace, unqualified_constant_name = Util.namespace_and_unqualified_constant_name(constant_name,
                                                                                          raise_if_namespace_invalid: true)
      if filename_or_filenames
        filename_or_filenames == namespace.autoload?(unqualified_constant_name)
      else
        namespace.autoload? unqualified_constant_name
      end
    end
  end

  chain :from_file do |filename|
    @filename_or_filenames = filename
  end

  chain :from_files do |*filenames|
    @filename_or_filenames = filenames
  end

  description do
    fragments = []
    fragments << "constant #{constant_name}"
    if filename_or_filenames
      unless (filenames = Array(filename_or_filenames)).empty?
        fragments << "from file#{(filenames.length == 1) ? nil : 's'} #{filenames.join ' and '}"
      end
    end
    "set up #{Module.name}#autoload? for #{fragments.join ' '}"
  end

  attr_reader :filename_or_filenames
end
