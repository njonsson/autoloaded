RSpec.describe Autoloaded::Specification do
  before :each do
    allow(inflector_class).to receive(:to_constant_name).
                              and_return(:FromInflection1,
                                         :FromInflection2,
                                         :FromInflection3)
  end

  subject(:specification) { specification_class.new(*elements) }

  let(:specification_class) { described_class }

  let(:inflector_class) { Autoloaded::Inflection }

  specify("equals equivalent #{described_class.name}") {
    expect(specification_class.new('foo')).to eq(specification_class.new('foo'))
  }

  specify("doesn't equal #{Object.name}") {
    expect(specification_class.new('foo')).not_to eq(Object.new)
  }

  specify("doesn't equal #{described_class.name} with different #elements") {
    expect(specification_class.new('foo')).not_to eq(specification_class.new('bar'))
  }

  describe 'with no elements' do
    let(:elements) { [] }

    specify { expect(specification.match('foo/bar')).to be_nil }
  end

  describe 'with one nonmatching element' do
    let(:elements) { ['foo/bar'] }

    specify { expect(specification.match('foo/baz')).to be_nil }
  end

  describe 'with one matching string element' do
    let(:elements) { ['FOO/BAR'] }

    specify { expect(specification.match('foo/bar')).to eq(:FromInflection1) }
  end

  describe 'with one matching symbol element' do
    let(:elements) { [:FROMINFLECTION1] }

    specify { expect(specification.match('foo/bar')).to eq(:FROMINFLECTION1) }
  end

  describe 'with two string elements, the second of which is matching' do
    let(:elements) { %w(foo/bar baz/qux) }

    specify { expect(specification.match('baz/qux')).to eq(:FromInflection1) }
  end

  describe 'with two symbol elements, the second of which is matching' do
    let(:elements) { [:Foo, :FromInflection2] }

    specify { expect(specification.match('baz/qux')).to eq(:FromInflection2) }
  end

  describe 'with a nonmatching hash element' do
    let(:elements) { [{Foo: 'bar/baz'}] }

    specify { expect(specification.match('bar/qux')).to be_nil }
  end

  describe 'with a hash element in which a key matches' do
    let(:elements) { [{FromInflection1: 'bar/baz'}] }

    specify { expect(specification.match('foo')).to eq('bar/baz') }
  end

  describe 'with a hash element in which a value matches' do
    let(:elements) { [{Foo: 'bar/baz'}] }

    specify { expect(specification.match('bar/baz')).to eq(:Foo) }
  end

  describe 'with a hash element in which an array key has a match' do
    let(:elements) { [{[:Foo, :FromInflection2] => 'bar/baz'}] }

    specify { expect(specification.match('qux')).to eq('bar/baz') }
  end

  describe 'with a hash element in which a an array value has a match' do
    let(:elements) { [{Foo: %w(bar/baz qux/quux)}] }

    specify { expect(specification.match('qux/quux')).to eq(:Foo) }
  end

  describe 'with a nonmatching string and a hash element in which an array key has a match' do
    let(:elements) { ['foo', {[:Bar, :FromInflection2] => 'baz/qux'}] }

    specify { expect(specification.match('quux')).to eq('baz/qux') }
  end
end
