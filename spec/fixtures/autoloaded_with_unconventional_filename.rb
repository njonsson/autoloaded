require 'autoloaded'

module AutoloadedWithUnconventionalFilename

  autoload :OldSchoolAutoload,
           'fixtures/autoloaded_with_unconventional_filename/old_school_autoload'

  ::Autoloaded.module do |autoloaded|
    autoloaded.only 'N-est-ed' => [:Nested1, :Nested2]
  end

end
