require 'autoloaded'

module AutoloadedWithConventionalFilename

  autoload :OldSchoolAutoload,
           'fixtures/old_api/autoloaded_with_conventional_filename/old_school_autoload'

  extend ::Autoloaded

end
