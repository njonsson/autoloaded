require 'autoloaded/constant'

RSpec.describe Autoloaded::Constant do
  let(:constant_class) { described_class }

  describe 'for' do
    let(:directory) { 'spec/fixtures/filenames' }

    {AFilename:  %w(a_filename  a-file-name a-filename a_file_name             AFilename),
     A_FILENAME: %w(a_filename  a-file-name a-filename a_file_name             AFilename),
     AFileName:  %w(a_file_name a-file-name a-filename             a_filename  AFilename),
     AFILEName:  %w(a-file-name             a-filename a_file_name a_filename  AFilename)}.each do |constant_name,
                                                                                                    filenames|
      describe constant_name.inspect do
        let(:constant) { constant_class.new constant_name }

        let(:full_filenames) {
          filenames.collect do |filename|
            "#{directory}/#{filename}.rb"
          end
        }

        describe '#each_matching_filename_in' do
          specify {
            expect { |block|
              constant.each_matching_filename_in(directory, &block)
            }.to yield_successive_args(*full_filenames)
          }
        end
      end
    end
  end
end
