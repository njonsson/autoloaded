require 'stringio'

RSpec.describe Autoloaded::Deprecation do
  before :each do
    deprecation_module.io = io
  end

  let(:deprecation_module) { described_class }

  let(:io) { StringIO.new }

  describe '.deprecate' do
    before :each do
      deprecation_module.deprecate deprecated_usage: 'foo',
                                   sanctioned_usage: 'bar',
                                   source_filename:  'baz.rb'
    end

    specify('writes the expected message to .io') {
      expect(io.string).to eq(%Q(\e[33m*** \e[7m DEPRECATED \e[0m \e[4mfoo\e[0m -- use \e[4mbar\e[0m instead in baz.rb\n))
    }
  end
end
