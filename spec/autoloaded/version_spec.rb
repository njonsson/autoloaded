require 'autoloaded/version'
require 'autoloaded'

RSpec.describe "#{Autoloaded.name}::VERSION" do
  specify { expect(Autoloaded::VERSION).to match( /^\d+\.\d+\.\d+/ ) }
end
