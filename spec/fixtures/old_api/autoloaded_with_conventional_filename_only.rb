require 'autoloaded'

module AutoloadedWithConventionalFilenameOnly

  autoload :OldSchoolAutoload,
           'fixtures/old_api/autoloaded_with_conventional_filename_only/old_school_autoload'

  extend ::Autoloaded

end
