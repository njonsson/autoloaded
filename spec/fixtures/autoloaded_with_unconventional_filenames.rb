require 'autoloaded'

module AutoloadedWithUnconventionalFilenames

  autoload :OldSchoolAutoload,
           'fixtures/autoloaded_with_unconventional_filenames/old_school_autoload'

  extend ::Autoloaded

end
