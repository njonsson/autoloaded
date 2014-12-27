RSpec.describe Autoloaded::Specifications do
  subject(:specifications) { specifications_class.new }

  let(:specifications_class) { described_class }

  describe 'empty' do
    describe '#except' do
      subject(:except) { specifications.except }

      specify { is_expected.to be_empty }
    end

    describe '#only' do
      subject(:only) { specifications.only }

      specify { is_expected.to be_empty }
    end

    describe '#with' do
      subject(:with) { specifications.with }

      specify { is_expected.to be_empty }
    end

    describe '#validate! :except' do
      specify { expect { specifications.validate! :except }.not_to raise_error }
    end

    describe '#validate! :only' do
      specify { expect { specifications.validate! :only }.not_to raise_error }
    end

    describe '#validate! :with' do
      specify { expect { specifications.validate! :with }.not_to raise_error }
    end
  end

  describe 'with #except' do
    before :each do
      specifications.except << :foo
    end

    describe '#except' do
      subject(:except) { specifications.except }

      specify { is_expected.to contain_exactly(:foo) }
    end

    describe '#only' do
      subject(:only) { specifications.only }

      specify { is_expected.to be_empty }
    end

    describe '#with' do
      subject(:with) { specifications.with }

      specify { is_expected.to be_empty }
    end

    describe '#validate! :except' do
      specify { expect { specifications.validate! :except }.not_to raise_error }
    end

    describe '#validate! :only' do
      specify { expect { specifications.validate! :only }.not_to raise_error }
    end

    describe '#validate! :with' do
      specify { expect { specifications.validate! :with }.not_to raise_error }
    end

    describe 'and #only' do
      before :each do
        specifications.only << :bar
      end

      describe '#except' do
        subject(:except) { specifications.except }

        specify { is_expected.to contain_exactly(:foo) }
      end

      describe '#only' do
        subject(:only) { specifications.only }

        specify { is_expected.to contain_exactly(:bar) }
      end

      describe '#with' do
        subject(:with) { specifications.with }

        specify { is_expected.to be_empty }
      end

      describe '#validate! :except' do
        specify {
          expect {
            specifications.validate! :except
          }.to raise_error(RuntimeError,
                           "can't specify `except' when `only' is already specified")
        }
      end

      describe '#validate! :only' do
        specify {
          expect {
            specifications.validate! :only
          }.to raise_error(RuntimeError,
                           "can't specify `only' when `except' is already specified")
        }
      end

      describe '#validate! :with' do
        specify { expect { specifications.validate! :with }.not_to raise_error }
      end
    end
  end

  describe 'with #only' do
    before :each do
      specifications.only << :foo
    end

    describe '#except' do
      subject(:except) { specifications.except }

      specify { is_expected.to be_empty }
    end

    describe '#only' do
      subject(:only) { specifications.only }

      specify { is_expected.to contain_exactly(:foo) }
    end

    describe '#with' do
      subject(:with) { specifications.with }

      specify { is_expected.to be_empty }
    end

    describe '#validate! :except' do
      specify { expect { specifications.validate! :except }.not_to raise_error }
    end

    describe '#validate! :only' do
      specify { expect { specifications.validate! :only }.not_to raise_error }
    end

    describe '#validate! :with' do
      specify { expect { specifications.validate! :with }.not_to raise_error }
    end
  end

  describe 'with #with' do
    before :each do
      specifications.with << :foo
    end

    describe '#except' do
      subject(:except) { specifications.except }

      specify { is_expected.to be_empty }
    end

    describe '#only' do
      subject(:only) { specifications.only }

      specify { is_expected.to be_empty }
    end

    describe '#with' do
      subject(:with) { specifications.with }

      specify { is_expected.to contain_exactly(:foo) }
    end

    describe '#validate! :except' do
      specify { expect { specifications.validate! :except }.not_to raise_error }
    end

    describe '#validate! :only' do
      specify { expect { specifications.validate! :only }.not_to raise_error }
    end

    describe '#validate! :with' do
      specify { expect { specifications.validate! :with }.not_to raise_error }
    end
  end
end
