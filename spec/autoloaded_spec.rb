require 'autoloaded'
require 'matchers'

RSpec.describe Autoloaded do
  if ENV['CI'] && (ENV['CI'].to_s != 'false')
    pending "examples can't be run under CI due to process forking"
  else
    describe 'not extending a namespace' do
      let(:source_file) { 'spec/fixtures/namespace_that_is_not_autoloaded.rb' }

      specify('does not dynamically define a nested constant') {
        expect(source_file).not_to autoload_a_constant_named('NamespaceThatIsNotAutoloaded::Nested')
      }
    end

    describe 'extending a namespace' do
      describe 'whose source files have conventional names' do
        let(:source_file) {
          'spec/fixtures/namespace_that_is_autoloaded_conventionally.rb'
        }

        specify('dynamically defines a nested constant stored in a conventionally-named file') {
          expect(source_file).to autoload_a_constant_named('NamespaceThatIsAutoloadedConventionally::Nested')
        }

        specify('does not pollute the namespace') {
          expect(source_file).to define_only_constants_named(:Nested).
                                 in_a_namespace_named(:NamespaceThatIsAutoloadedConventionally)
        }
      end

      describe 'whose source files have unconventional names' do
        let(:source_file) {
          'spec/fixtures/namespace_that_is_autoloaded_unconventionally.rb'
        }

        specify('dynamically defines a nested constant stored in a unconventionally-named file') {
          expect(source_file).to autoload_a_constant_named('NamespaceThatIsAutoloadedUnconventionally::Nested')
        }

        specify('does not pollute the namespace') {
          expect(source_file).to define_only_constants_named(:Nested).
                                 in_a_namespace_named(:NamespaceThatIsAutoloadedUnconventionally)
        }
      end
    end
  end
end
