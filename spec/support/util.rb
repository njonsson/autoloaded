module Util

  class << self

    def constantize(name)
      return nil unless name

      begin
        eval name.to_s
      rescue NameError
        nil
      end
    end

    def namespace_and_unqualified_constant_name(constant_name,
                                                raise_if_namespace_invalid: false)
      namespace_name, unqualified_constant_name = split_namespace_and_constant(constant_name)
      if namespace_name && (namespace = constantize(namespace_name)).nil?
        if raise_if_namespace_invalid
          raise "namespace of #{constant_name} is not defined"
        end
      end
      [namespace, unqualified_constant_name]
    end

    def namespace_delimiter
      '::'
    end

  private

    def split_namespace_and_constant(constant_name)
      if (last_delimiter_index = constant_name.to_s.rindex(namespace_delimiter))
        return [constant_name[0...last_delimiter_index],
                constant_name[(last_delimiter_index + namespace_delimiter.length)..-1]]
      end

      return [nil, constant_name]
    end

  end

end
