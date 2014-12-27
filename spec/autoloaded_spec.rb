require 'autoloaded_macro_sharedspec'
require 'matchers'
require 'stringio'

RSpec.describe Autoloaded do
  let(:autoloaded_module) { described_class }

  let(:warning_module) { autoloaded_module::Warning }

  describe '.class' do
    it_behaves_like "an #{Autoloaded.name} macro", :class
  end

  describe '.module' do
    it_behaves_like "an #{Autoloaded.name} macro", :module
  end

  describe '.warn' do
    describe 'simple form' do
      before :each do
        allow(warning_module).to receive(:enable).
                                 and_return(:warning_enable_result)
      end

      specify("delegates to #{Autoloaded::Warning.name}.enable") {
        expect(warning_module).to receive(:enable).
                                  with('foo').
                                  and_return(:warning_enable_result)
        autoloaded_module.warn 'foo'
      }

      specify("returns #{Autoloaded.name}") {
        expect(autoloaded_module.warn('foo')).to eq(autoloaded_module)
      }
    end

    describe 'block form' do
      specify("delegates to #{Autoloaded::Warning.name}.enable") {
        expect(warning_module).to receive(:enable).
                                  with('foo').
                                  and_yield.
                                  and_return(:warning_enable_result)
        result = autoloaded_module.warn('foo') do
          :block_result
        end
        expect(result).to eq(:warning_enable_result)
      }
    end
  end

  describe '.warn?' do
    specify("delegates to #{Autoloaded::Warning.name}.enabled?") {
      expect(warning_module).to receive(:enabled?).
                                and_return(:warning_enabled_result)
      expect(autoloaded_module.warn?).to eq(:warning_enabled_result)
    }
  end

  describe 'integration' do
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

          it {
            is_expected.to define_constant(:AutoloadedWithConventionalFilename)
          }

          it {
            is_expected.to define_constant('AutoloadedWithConventionalFilename::OldSchoolAutoload')
          }

          it {
            is_expected.to define_constant('AutoloadedWithConventionalFilename::Nested')
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
                           from_file('fixtures/autoloaded_with_conventional_filename/nested')
          }

          it {
            is_expected.not_to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::NONEXISTENT')
          }
        end

        describe 'unconventional source filenames' do
          subject(:source_file) {
            'spec/fixtures/autoloaded_with_unconventional_filename.rb'
          }

          it {
            is_expected.to define_constant(:AutoloadedWithUnconventionalFilename)
          }

          it {
            is_expected.to define_constant('AutoloadedWithUnconventionalFilename::OldSchoolAutoload')
          }

          it {
            is_expected.to define_constants('AutoloadedWithUnconventionalFilename::Nested1',
                                            'AutoloadedWithUnconventionalFilename::Nested2')
          }

          it {
            is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilename::OldSchoolAutoload').
                           from_file('fixtures/autoloaded_with_unconventional_filename/old_school_autoload')
          }

          it {
            is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilename::Nested1').
                           from_file('fixtures/autoloaded_with_unconventional_filename/N-est-ed')
          }

          it {
            is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilename::Nested2').
                           from_file('fixtures/autoloaded_with_unconventional_filename/N-est-ed')
          }

          it {
            is_expected.not_to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilename::NONEXISTENT')
          }
        end
      end
    end

    describe 'old API' do
      before :each do
        autoloaded_module::Deprecation.io = StringIO.new
      end

      after :each do
        autoloaded_module::Deprecation.io = nil
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
          subject(:source_file) { 'spec/fixtures/old_api/not_autoloaded.rb' }

          it { is_expected.to define_constant(:NotAutoloaded) }

          it {
            is_expected.to define_constant('NotAutoloaded::OldSchoolAutoload')
          }

          it { is_expected.not_to define_constant('NotAutoloaded::Nested') }

          it {
            is_expected.to set_up_autoload_for_constant('NotAutoloaded::OldSchoolAutoload').
                           from_file('fixtures/old_api/not_autoloaded/old_school_autoload')
          }

          it {
            is_expected.not_to set_up_autoload_for_constant('NotAutoloaded::Nested')
          }
        end

        describe 'extending a namespace whose constituent source files include' do
          describe 'a conventional source filename used for autoloading' do
            subject(:source_file) {
              'spec/fixtures/old_api/autoloaded_with_conventional_filename.rb'
            }

            it {
              is_expected.to define_constant(:AutoloadedWithConventionalFilename)
            }

            it {
              is_expected.to define_constant('AutoloadedWithConventionalFilename::OldSchoolAutoload')
            }

            it {
              is_expected.to define_constant('AutoloadedWithConventionalFilename::Nested')
            }

            it {
              is_expected.not_to define_constant('AutoloadedWithConventionalFilename::NONEXISTENT')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::OldSchoolAutoload').
                             from_file('fixtures/old_api/autoloaded_with_conventional_filename/old_school_autoload')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::Nested').
                             from_files('fixtures/old_api/autoloaded_with_conventional_filename/nested',
                                        'fixtures/old_api/autoloaded_with_conventional_filename/N-est-ed',
                                        'fixtures/old_api/autoloaded_with_conventional_filename/nest_ed')
            }

            it {
              is_expected.not_to set_up_autoload_for_constant('AutoloadedWithConventionalFilename::NONEXISTENT')
            }
          end

          describe 'a conventional source filename only' do
            subject(:source_file) {
              'spec/fixtures/old_api/autoloaded_with_conventional_filename_only.rb'
            }

            it {
              is_expected.to define_constant(:AutoloadedWithConventionalFilenameOnly)
            }

            it {
              is_expected.to define_constant('AutoloadedWithConventionalFilenameOnly::OldSchoolAutoload')
            }

            it {
              is_expected.to define_constant('AutoloadedWithConventionalFilenameOnly::Nested')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::OldSchoolAutoload').
                             from_file('fixtures/old_api/autoloaded_with_conventional_filename_only/old_school_autoload')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::Nested').
                             from_file('fixtures/old_api/autoloaded_with_conventional_filename_only/nested')
            }

            it {
              is_expected.not_to set_up_autoload_for_constant('AutoloadedWithConventionalFilenameOnly::NONEXISTENT')
            }
          end

          describe 'unconventional source filenames' do
            subject(:source_file) {
              'spec/fixtures/old_api/autoloaded_with_unconventional_filenames.rb'
            }

            it {
              is_expected.to define_constant(:AutoloadedWithUnconventionalFilenames)
            }

            it {
              is_expected.to define_constant('AutoloadedWithUnconventionalFilenames::OldSchoolAutoload')
            }

            it {
              is_expected.to define_constants('AutoloadedWithUnconventionalFilenames::Nested')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::OldSchoolAutoload').
                             from_file('fixtures/old_api/autoloaded_with_unconventional_filenames/old_school_autoload')
            }

            it {
              is_expected.to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::Nested').
                             from_files('fixtures/old_api/autoloaded_with_unconventional_filenames/N-est-ed',
                                        'fixtures/old_api/autoloaded_with_unconventional_filenames/nest_ed')
            }

            it {
              is_expected.not_to set_up_autoload_for_constant('AutoloadedWithUnconventionalFilenames::NONEXISTENT')
            }
          end
        end
      end
    end
  end
end
