require 'autoloaded'
require 'autoloaded/autoloader'

RSpec.shared_examples_for "an #{Autoloaded.name} macro" do |macro|
  before :each do
    allow(autoloader_class).to receive(:new).and_return(autoloader)
    allow_any_instance_of(autoloader_class).to receive(:autoload!)
  end

  let(:autoloaded_module) { Autoloaded }

  let(:autoloader) { autoloader_class.new binding }

  let(:autoloader_class) { autoloaded_module::Autoloader }

  specify("yields an #{Autoloaded::Autoloader.name}") {
    autoloaded_module.send macro do |autoloaded|
      expect(autoloaded).to equal(autoloader)
    end
  }

  specify("calls #{Autoloaded::Autoloader.name}#autoload!") {
    expect(autoloader).to receive(:autoload!)
    autoloaded_module.send macro do |autoloaded|
    end
  }
end
