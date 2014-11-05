require 'autoloaded'

module AutoloadedWithConventionalFilenameOnly

  autoload :OldSchoolAutoload,
           'fixtures/autoloaded_with_conventional_filename_only/old_school_autoload'

  extend ::Autoloaded

end
