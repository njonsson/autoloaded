# Fall back to monkeypatching if refinements are not supported.

unless ::Module.private_instance_methods.include?(:refine)
  class ::Module

  private

    def refine(klass, &block)
      klass.class_eval(&block)
    end

  end
end

unless private_methods.include?(:using)
  def using(*arguments); end
end
