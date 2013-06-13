# encoding: utf-8
require 'sparsify'

describe 'Sparsify' do
  let(:source_hash) do
    {'foo' => { 'bar' => {'baz'=>'bingo', 'whee'=> {}}}}
  end

  let(:intended_result) do
    {
      'foo.bar.baz' => 'bingo',
      'foo.bar.whee' => {}
    }
  end

  it 'should sparsify' do
    Sparsify(source_hash).should == intended_result
  end

  context 'round-trip' do
    subject do
      Unsparsify(Sparsify(source_hash, separator: '|'), separator: '|')
    end
    it { should == source_hash }
  end
end
