require 'stringio'

RSpec.describe Autoloaded::Warning do
  before :each do
    warning_module.io = io
  end

  let(:warning_module) { described_class }

  let(:io) { StringIO.new }

  describe '.enable' do
    describe 'simple form' do
      describe 'with nil argument' do
        specify('sets .enabled? as expected') {
          warning_module.enable nil
          expect(warning_module.enabled?).to eq(false)
        }
      end

      describe 'with false argument' do
        specify('sets .enabled? as expected') {
          warning_module.enable false
          expect(warning_module.enabled?).to eq(false)
        }
      end

      describe 'with string argument' do
        specify('sets .enabled? as expected') {
          warning_module.enable 'foo'
          expect(warning_module.enabled?).to eq(true)
        }
      end

      describe 'with true argument' do
        specify('sets .enabled? as expected') {
          warning_module.enable true
          expect(warning_module.enabled?).to eq(true)
        }
      end

      specify("returns #{Autoloaded::Warning.name}") {
        expect(warning_module.enable('foo')).to eq(warning_module)
      }
    end

    describe 'block form' do
      specify('returns the result of the block') {
        result = warning_module.enable('foo') do
          :block_result
        end
        expect(result).to eq(:block_result)
      }

      describe 'if the block returns' do
        specify('resets .enabled?') {
          expect {
            warning_module.enable(false) { }
          }.not_to change { warning_module.enabled? }
          expect {
            warning_module.enable(true) { }
          }.not_to change { warning_module.enabled? }
        }
      end

      describe 'if the block raises an error' do
        specify('resets .enabled?') {
          expect {
            begin
              warning_module.enable(false) do
                1 / 0
              end
            rescue ZeroDivisionError
            end
          }.not_to change { warning_module.enabled? }
          expect {
            begin
              warning_module.enable(true) do
                1 / 0
              end
            rescue ZeroDivisionError
            end
          }.not_to change { warning_module.enabled? }
        }
      end
    end
  end

  describe '.changing_autoload' do
    before :each do
      warning_module.enable true
      warning_module.changing_autoload constant_name:        :Foo,
                                       old_source_filename:  'bar',
                                       new_source_filename:  'baz',
                                       host_source_location: 'qux.rb:123'
    end

    specify('writes the expected message to .io') {
      expect(io.string).to eq(%Q(\e[33m*** \e[7m WARNING \e[0m Existing autoload of \e[4mFoo\e[0m from "bar" is being overridden to autoload from "baz" -- avoid this warning by using an \e[4monly\e[0m or an \e[4mexcept\e[0m specification in the block at qux.rb:123\n))
    }
  end

  describe '.existing_constant' do
    before :each do
      warning_module.enable true
      warning_module.existing_constant constant_name:        :Foo,
                                       source_filename:      'bar',
                                       host_source_location: 'baz.rb:123'
    end

    specify('writes the expected message to .io') {
      expect(io.string).to eq(%Q(\e[33m*** \e[7m WARNING \e[0m Existing definition of \e[4mFoo\e[0m obviates autoloading from "bar" -- avoid this warning by using an \e[4monly\e[0m or an \e[4mexcept\e[0m specification in the block at baz.rb:123\n))
    }
  end
end
