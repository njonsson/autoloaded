using Autoloaded::Refine::String::ToSourceFilename

RSpec.describe Autoloaded::Refine::String::ToSourceFilename do
  {'Foo'        => 'foo',
   'IO'         => 'io',
   'MySQL2'     => 'my_sql2',
   'PostgreSQL' => 'postgre_sql',
   'Geo3D'      => 'geo3_d',
   'Xfiles'     => 'xfiles',
   'XFiles'     => 'x_files',
   'FOOBar'     => 'foo_bar',
   'FOO_BAR'    => 'foo_bar'}.each do |constant_name, filename|
    describe "for #{constant_name.inspect}" do
      describe '#to_source_filename' do
        specify { expect(constant_name.to_source_filename).to eq(filename) }
      end
    end
  end
end
