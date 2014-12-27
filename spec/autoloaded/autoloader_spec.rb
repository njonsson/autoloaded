RSpec.describe Autoloaded::Autoloader do
  subject(:autoloader) { autoloader_class.new host_binding }

  before :each do
    allow(specifications_class).to receive(:new).and_return(specifications)
    allow(inflector_class).to receive(:to_constant_name).
                              and_return(:FromInflection1,
                                         :FromInflection2,
                                         :FromInflection3,
                                         :FromInflection4)
  end

  let(:autoloader_class) { described_class }

  let(:host_binding) { self.class.class_eval 'binding', __FILE__, __LINE__ }

  let(:directory_class) { Autoloaded::LoadPathedDirectory }

  let(:specifications) { specifications_class.new }

  let(:specifications_class) { Autoloaded::Specifications }

  let(:specification_class) { Autoloaded::Specification }

  let(:inflector_class) { Autoloaded::Inflection }

  describe '.new' do
    describe 'with nil argument' do
      specify {
        expect { autoloader_class.new nil }.to raise_error(ArgumentError,
                                                           "can't be nil")
      }
    end
  end

  describe '#from' do
    subject(:from) { autoloader.from }

    describe 'has expected default value' do
      specify { is_expected.to eq(__FILE__.gsub(/\.rb$/, '')) }
    end

    describe 'rejects relative path argument' do
      specify {
        expect {
          autoloader.from 'a/relative/path'
        }.to raise_error(ArgumentError, "can't be relative")
      }
    end

    describe 'operates as attribute reader and writer' do
      specify {
        autoloader.from '/an/absolute/path'
        is_expected.to eq('/an/absolute/path')
      }
    end
  end

  describe '#except' do
    specify("delegates to #{Autoloaded::Specifications.name}#except") {
      expect(specifications.except).to be_empty
      autoloader.except 'foo'
      expect(specifications.except).to contain_exactly(specification_class.new('foo'))
    }

    describe 'where #only is specified' do
      before :each do
        autoloader.only :Foo
      end

      specify {
        expect { autoloader.except :Bar }.to raise_error(RuntimeError,
                                                         "can't specify `except' when `only' is already specified")
      }
    end
  end

  describe '#only' do
    specify("delegates to #{Autoloaded::Specifications.name}#only") {
      expect(specifications.only).to be_empty
      autoloader.only 'foo'
      expect(specifications.only).to contain_exactly(specification_class.new('foo'))
    }

    describe 'where #except is specified' do
      before :each do
        autoloader.except :Foo
      end

      specify {
        expect { autoloader.only :Bar }.to raise_error(RuntimeError,
                                                       "can't specify `only' when `except' is already specified")
      }
    end
  end

  describe '#with' do
    specify("delegates to #{Autoloaded::Specifications.name}#with") {
      expect(specifications.with).to be_empty
      autoloader.with 'foo'
      expect(specifications.with).to contain_exactly(specification_class.new('foo'))
    }
  end

  describe '#autoload!' do
    before :each do
      allow_any_instance_of(directory_class).to receive(:closest_ruby_load_path).
                                                and_return('/foo')
      allow(directory_class).to receive(:new).and_return(directory)
      allow(directory).to receive(:each_source_filename)
    end

    let(:directory) { directory_class.new '/foo' }

    describe 'where #from is' do
      describe 'not specified' do
        describe "initializes #{Autoloaded::LoadPathedDirectory.name} with computed value" do
          specify {
            expect(directory_class).to receive(:new).
                                       with(__FILE__.gsub(/\.rb$/, '')).
                                       and_return(directory)
            autoloader.autoload!
          }
        end
      end

      describe 'specified' do
        before :each do
          autoloader.from directory.path
          allow(specifications).to receive(:except).
                                   and_return(except_specifications)
          allow(specifications).to receive(:only).
                                   and_return(only_specifications)
          allow(specifications).to receive(:with).
                                   and_return(with_specifications)
        end

        let(:except_specifications) { [] }

        let(:except_specification) { specification_class.new }

        let(:only_specifications) { [] }

        let(:only_specification) { specification_class.new }

        let(:with_specifications) { [] }

        let(:with_specification) { specification_class.new }

        describe 'where no source files are found' do
          specify {
            expect(Kernel).not_to receive(:eval)
            autoloader.autoload!
          }

          specify { expect(autoloader.autoload!).to be_empty }
        end

        describe 'where a source file is found' do
          before :each do
            allow(directory).to receive(:each_source_filename).
                                and_yield('from_each_source_filename')
          end

          describe 'and no specifications are provided' do
            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection1, "from_each_source_filename"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify {
              expect(autoloader.autoload!).to eq([[:FromInflection1,
                                                   'from_each_source_filename']])
            }
          end

          describe "and a `with' specification is provided" do
            before :each do
              allow(with_specification).to receive(:match).and_return(:FromWith)
            end

            let(:with_specifications) { [with_specification] }

            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromWith',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromWith',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromWith, "from_each_source_filename"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric))
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify {
              expect(autoloader.autoload!).to eq([[:FromWith,
                                                   'from_each_source_filename']])
            }
          end

          describe "and an `only' specification is provided" do
            before :each do
              allow(only_specification).to receive(:match).and_return(:FromOnly)
            end

            let(:only_specifications) { [only_specification] }

            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromOnly',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromOnly',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromOnly, "from_each_source_filename"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify { expect(autoloader.autoload!).to eq([[:FromOnly,
                                                           'from_each_source_filename']]) }
          end

          describe "and both `with' and `only' specifications are provided" do
            before :each do
              allow(with_specification).to receive(:match).and_return(:FromWith)
              allow(only_specification).to receive(:match).and_return(:FromOnly)
            end

            let(:with_specifications) { [with_specification] }

            let(:only_specifications) { [only_specification] }

            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromWith',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromWith',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromWith, "from_each_source_filename"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify { expect(autoloader.autoload!).to eq([[:FromWith,
                                                           'from_each_source_filename']]) }
          end
        end

        describe 'where multiple source files are found' do
          before :each do
            allow(directory).to receive(:each_source_filename).
                                and_yield('from_each_source_filename1').
                                and_yield('from_each_source_filename2').
                                and_yield('from_each_source_filename3')
          end

          describe 'and no specifications are provided' do
            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection1, "from_each_source_filename1"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection2',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection2',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection2, "from_each_source_filename2"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection3',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection3',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection3, "from_each_source_filename3"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify {
              expect(autoloader.autoload!).to eq([[:FromInflection1,
                                                   'from_each_source_filename1'],
                                                  [:FromInflection2,
                                                   'from_each_source_filename2'],
                                                  [:FromInflection3,
                                                   'from_each_source_filename3']])
            }
          end

          describe "and a matching `except' specification is provided" do
            before :each do
              allow(except_specification).to receive(:match).
                                             with('from_each_source_filename1').
                                             and_return(nil)
              allow(except_specification).to receive(:match).
                                             with('from_each_source_filename2').
                                             and_return(:FromExcept)
              allow(except_specification).to receive(:match).
                                             with('from_each_source_filename3').
                                             and_return(nil)
            end

            let(:except_specifications) { [except_specification] }

            specify {
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection1',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection1, "from_each_source_filename1"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload? :FromInflection2',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('constants.include? :FromInflection2',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              expect(Kernel).to receive(:eval).
                                with('autoload :FromInflection2, "from_each_source_filename3"',
                                #      host_binding,
                                #      kind_of(String),
                                #      kind_of(Numeric)).
                                     host_binding).
                                ordered
              autoloader.autoload!
            }

            specify {
              expect(autoloader.autoload!).to eq([[:FromInflection1,
                                                   'from_each_source_filename1'],
                                                  [:FromInflection2,
                                                   'from_each_source_filename3']])
            }
          end
        end
      end
    end
  end
end
