RSpec.describe Autoloaded::LoadPathedDirectory do
  before :each do
    allow(directory_class).to receive(:ruby_load_paths).
                              and_return(ruby_load_paths)
  end

  subject(:directory) { directory_class.new path }

  let(:directory_class) { described_class }

  let(:ruby_load_paths) { [Dir.pwd] }

  describe '.new' do
    describe 'with a nil argument' do
      specify {
        expect { directory_class.new nil }.to raise_error(ArgumentError,
                                                          "can't be nil")
      }
    end

    describe 'with a relative-path argument' do
      specify {
        expect { directory_class.new 'foo' }.to raise_error(ArgumentError,
                                                            "can't be relative")
      }
    end
  end

  describe 'with an absolute #path' do
    let(:path) { File.expand_path 'spec/fixtures/filenames' }

    let(:expected_relative_source_filenames) {
      %w(a-file-name
         a-filename
         a_file_name
         a_filename
         afile-name
         afile_name
         AFilename)
    }

    describe '#path' do
      subject { directory.path }

      specify { is_expected.to eq(path) }
    end

    describe '#each_source_filename' do
      subject(:yielded_arguments) {
        result = []
        directory.each_source_filename do |source_filename|
          result << source_filename
        end
        result
      }

      describe 'where #path does not match a Ruby load path' do
        let(:ruby_load_paths) { [] }

        let(:expected_source_filenames) {
          expected_relative_source_filenames.collect do |f|
            File.expand_path f, 'spec/fixtures/filenames'
          end
        }

        describe 'yielded arguments' do
          specify('should be absolute paths to the expected source filenames') {
            is_expected.to match_array(expected_source_filenames)
          }
        end
      end

      describe 'where #path partially matches one Ruby load path' do
        let(:expected_source_filenames) {
          expected_relative_source_filenames.collect do |f|
            File.join 'spec/fixtures/filenames', f
          end
        }

        describe 'yielded arguments' do
          specify('should be partial paths to the expected source filenames') {
            is_expected.to match_array(expected_source_filenames)
          }
        end
      end

      describe 'where #path partially matches multiple Ruby load paths' do
        let(:ruby_load_paths) {
          [Dir.pwd,
           File.join(Dir.pwd, 'spec/fixtures'),
           File.join(Dir.pwd, 'spec')]
        }

        let(:expected_source_filenames) {
          expected_relative_source_filenames.collect do |f|
            File.join 'filenames', f
          end
        }

        describe 'yielded arguments' do
          specify('should be partial paths to the expected source filenames') {
            is_expected.to match_array(expected_source_filenames)
          }
        end
      end

      describe 'where #path exactly matches a Ruby load path' do
        let(:ruby_load_paths) { [File.join(Dir.pwd, 'spec/fixtures/filenames')] }

        let(:expected_source_filenames) { expected_relative_source_filenames }

        describe 'yielded arguments' do
          specify('should be the expected source filenames') {
            is_expected.to match_array(expected_source_filenames)
          }
        end
      end
    end
  end
end
