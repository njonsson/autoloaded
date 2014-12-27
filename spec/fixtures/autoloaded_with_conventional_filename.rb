require 'autoloaded'

module AutoloadedWithConventionalFilename

  autoload :OldSchoolAutoload,
           'fixtures/autoloaded_with_conventional_filename/old_school_autoload'

  ::Autoloaded.module do |autoloaded|
    autoloaded.except 'N-est-ed', 'nest_ed'
  end

end
