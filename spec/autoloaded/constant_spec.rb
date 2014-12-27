RSpec.describe Autoloaded::Constant do
  let(:constant_class) { described_class }

  specify("sanity check: load path includes our 'spec' directory") {
    expect($:).to include(File.expand_path('../..', __FILE__))
  }

  describe 'for' do
    let(:directory) { File.expand_path '../../fixtures/filenames', __FILE__ }

    let(:load_pathed_directory) {
      directory.gsub(/^#{File.expand_path '../..', __FILE__}\/?/, '')
    }

    {AFilename:  %w(a_filename  a-file-name a-filename a_file_name             afile_name afile-name AFilename),
     A_FILENAME: %w(a_filename  a-file-name a-filename a_file_name             afile_name afile-name AFilename),
     AFileName:  %w(a_file_name a-file-name a-filename             a_filename  afile_name afile-name AFilename),
     AFILEName:  %w(afile_name  a-file-name a-filename a_file_name a_filename             afile-name AFilename)}.each do |constant_name,
                                                                                                                          filenames|
      describe constant_name.inspect do
        let(:constant) { constant_class.new constant_name }

        let(:load_pathed_filenames) {
          filenames.collect do |filename|
            "#{load_pathed_directory}/#{filename}"
          end
        }

        describe '#each_matching_filename_in' do
          let(:yielded_args) {
            result = []
            constant.each_matching_filename_in directory do |filename|
              result << filename
            end
            result
          }

          describe 'first yielded argument' do
            subject(:first_yielded_argument) { yielded_args.first }

            it { is_expected.to eq(load_pathed_filenames.first) }
          end

          describe 'subsequent yielded arguments' do
            subject(:subsequent_yielded_arguments) { yielded_args[1..-1] }

            it { is_expected.to match_array(load_pathed_filenames[1..-1]) }
          end
        end
      end
    end
  end
end
