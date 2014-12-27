require 'autoloaded'

module AutoloadedWithConventionalFilename

  module Nested

    # module DoublyNested; end
    # autoload :DoublyNested, 'somewhere/else'

    ::Autoloaded.module { }

    DoublyNested

  end

end
