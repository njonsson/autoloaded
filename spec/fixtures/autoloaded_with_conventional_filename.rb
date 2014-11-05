require 'autoloaded'

module AutoloadedWithConventionalFilename

  autoload :OldSchoolAutoload,
           'fixtures/autoloaded_with_conventional_filename/old_school_autoload'

  extend ::Autoloaded

end
