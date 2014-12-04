require 'autoloaded'
require 'matchers'

RSpec.describe Autoloaded do
  before :each do
    class << self
      alias_method :define_constant, :define_constants
    end
  end

  begin
    fork do
      # The codeclimate-test-reporter RubyGem uses Kernel#at_exit to hook the
      # end of test/spec runs for sending coverage statistics to their web
      # service. We need to skip that hook in this process fork because this is
      # not the end of a test/spec run, only of a process fork.
      exit!(true) if ENV['CODECLIMATE_REPO_TOKEN']
    end
  rescue NotImplementedError => e
    pending "[pending because #{e.message}]"
  else
    describe 'not extending a namespace' do
      subject(:source_file) { 'spec/fixtures/not_autoloaded.rb' }

      it { is_expected.to define_constant(:NotAutoloaded) }

      it { is_expected.to define_constant('NotAutoloaded::OldSchoolAutoload') }

      it { is_expected.not_to define_constant('NotAutoloaded::Nested') }

      it {
        is_expected.to set_up_autoload_for_constant('NotAutoloaded::OldSchoolAutoload').
                       from_file('fixtures/not_autoloaded/old_school_autoload')
      }

      it {
        is_expected.not_to set_up_autoload_for_constant('NotAutoloaded::Nested')
      }
    end

    describe 'extending a namespace whose constituent source files include' do
      describe 'a conventional source filename used for autoloading' do
        subject(:source_file) {
          'spec/fixtures/autoloaded_with_conventional_filename.rb'
        }

        it { is_expected.to define_constant(:AutoloadedWithConventionalFilename) }

        it {
          is_expected.to define_constant('AutoloadedWithConventionalFilename::OldSchoolAutoload')
        }

        it {
          is_expected.to define_constant('AutoloadedWithConventionalFilename::Nested').
                         dynamically
        }

        it {
          is_expected.not_to define_constant('AutoloadedWithConventionalFilename::NONEXISTENT')
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::OldSchoolAutoload').
                         from_file('fixtures/autoloaded_with_conventional_filename/old_school_autoload')
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::Nested').
                         from_files('fixtures/autoloaded_with_conventional_filename/nested',
                                    'fixtures/autoloaded_with_conventional_filename/N-est-ed',
                                    'fixtures/autoloaded_with_conventional_filename/nest_ed')
        }

        it {
          is_expected.not_to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::NONEXISTENT')
        }
      end

      describe 'a conventional source filename only' do
        subject(:source_file) {
          'spec/fixtures/autoloaded_with_conventional_filename_only.rb'
        }

        it { is_expected.to define_constant(:AutoloadedWithConventionalFilenameOnly) }

        it {
          is_expected.to define_constant('AutoloadedWithConventionalFilenameOnly::OldSchoolAutoload')
        }

        it {
          is_expected.to define_constant('AutoloadedWithConventionalFilenameOnly::Nested').
                         dynamically
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::OldSchoolAutoload').
                         from_file('fixtures/autoloaded_with_conventional_filename_only/old_school_autoload')
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::Nested').
                         from_file('fixtures/autoloaded_with_conventional_filename_only/nested')
        }

        it {
          is_expected.not_to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::NONEXISTENT')
        }
      end

      describe 'unconventional source filenames' do
        subject(:source_file) {
          'spec/fixtures/autoloaded_with_unconventional_filenames.rb'
        }

        it {
          is_expected.to define_constant(:AutoloadedWithUnconventionalFilenames)
        }

        it {
          is_expected.to define_constant('AutoloadedWithUnconventionalFilenames::OldSchoolAutoload')
        }

        it {
          is_expected.to define_constants('AutoloadedWithUnconventionalFilenames::Nested').
                         dynamically
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::OldSchoolAutoload').
                         from_file('fixtures/autoloaded_with_unconventional_filenames/old_school_autoload')
        }

        it {
          is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::Nested').
                         from_files('fixtures/autoloaded_with_unconventional_filenames/N-est-ed',
                                    'fixtures/autoloaded_with_unconventional_filenames/nest_ed')
        }

        it {
          is_expected.not_to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::NONEXISTENT')
        }
      end
    end
  end
end
