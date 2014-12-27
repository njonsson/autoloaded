RSpec.describe Autoloaded::Inflection do
  subject(:inflection_module) { described_class }

  def self.make_source_filename(source_basename)
    "path/to/#{source_basename}.rb"
  end

  {'x'         => :X,
   'foo_bar'   => :FooBar,
   'foo__bar'  => :FooBar,
   '__foo_bar' => :FooBar,
   'foo-bar'   => :FooBar,
   'foo--bar'  => :FooBar,
   '--foo-bar' => :FooBar,
   'FooBar'    => :FooBar,
   'FOO_BAR'   => :FOO_BAR,
   'FOO-BAR'   => :FOO_BAR,
   'FOO--BAR'  => :FOO_BAR,
   'foo7bar'   => :Foo7bar}.each do |source_basename, expected_constant_name|
    describe %Q{for #{make_source_filename(source_basename).inspect}"} do
      describe '#to_constant_name' do
        specify {
          source_filename = self.class.make_source_filename(source_basename)
          constant_name   = inflection_module.to_constant_name(source_filename)
          expect(constant_name).to eq(expected_constant_name)
        }
      end
    end
  end
end
