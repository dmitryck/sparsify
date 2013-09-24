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

  context 'sparse_array' do
    let(:source_hash) do
      {'foo' => ['bar','baz',{'bingo'=>'baby'}]}
    end
    let(:intended_result) do
      {
        'foo.0' => 'bar',
        'foo.1' => 'baz',
        'foo.2.bingo' => 'baby'
      }
    end
    it 'should sparsify' do
      Sparsify(source_hash, sparse_array: true).should == intended_result
    end
    context 'round-trip' do
      subject do
        Unsparsify(Sparsify(source_hash, sparse_array: true), sparse_array: true)
      end
      it { should == source_hash }
    end
    context 'zero-pad' do
      let(:source_hash) do
        {'foo' => ['bar','baz',{'bingo'=>'baby'},'blip','blip','blip','blip','blip','blip','blip','blip']}
      end
      let(:intended_result) do
        {
          'foo.00' => 'bar',
          'foo.01' => 'baz',
          'foo.02.bingo' => 'baby',
          'foo.03' => 'blip',
          'foo.04' => 'blip',
          'foo.05' => 'blip',
          'foo.06' => 'blip',
          'foo.07' => 'blip',
          'foo.08' => 'blip',
          'foo.09' => 'blip',
          'foo.10' => 'blip',
        }
      end
      it 'should sparsify' do
        Sparsify(source_hash, sparse_array: :zero_pad).should == intended_result
      end
    end
  end

  context '.sparse_each' do
    context 'when no block given' do
      let(:sparse_each_result) { Sparsify.sparse_each(source_hash) }
      context 'the result' do
        subject { sparse_each_result }
        it { should be_an_instance_of Enumerator }
      end
    end

    context 'with block given' do
      it 'should yield all entries from the sparse hash' do
        expect do |b|
          Sparsify.sparse_each(source_hash, &b)
        end.to yield_successive_args(*intended_result.to_a)
      end
    end
  end

  context '.sparse_fetch' do
    let(:fetch_args) { [source_hash, search_key] }
    let(:the_intended_result) { intended_result[search_key] }
    let(:the_fetcher) do
      proc { |block| Sparsify.sparse_fetch(*fetch_args, &block) }
    end
    let(:the_result) { the_fetcher.call }
    let(:fetch_block) { nil }
    context 'when fetching an existing key' do
      let(:search_key) { 'foo.bar.baz' }
      context 'the result' do
        subject { the_result }
        it { should == the_intended_result }
      end
    end
    context 'when fetching an existing partial key' do
      context 'the result' do
        let(:search_key) { 'foo.bar' }
        let(:the_intended_result) { source_hash['foo']['bar'] }
        subject { the_result }
        it { should eq the_intended_result }
      end
    end
    context 'when fetching a missing key' do
      let(:search_key) { 'fiddle.foodle' }
      context 'with default supplied' do
        let(:fetch_args) { [source_hash, search_key, default_value] }
        let(:default_value) { :some_default }
        it 'should return the default' do
          the_result.should eq default_value
        end
      end
      context 'with alternate block supplied' do
        it 'should yield the block' do
          expect { |b| the_fetcher.call(b) }.to yield_with_no_args
        end
        context 'the return value' do
          let(:default_value) { :some_default }
          let(:default_proc) { proc { default_value } }
          subject { the_fetcher.call(default_proc)}
          it { should eq default_value }
        end
      end
      specify { expect { the_result }.to raise_exception KeyError }
    end
  end

  context '.sparse_get' do
    let(:get_args) { [source_hash, search_key] }
    let(:the_getter) do
      proc { |block| Sparsify.sparse_fetch(*get_args, &block) }
    end
    let(:the_result) { the_getter.call }

    context 'when getting an existing key' do
      let(:the_intended_result) { intended_result[search_key] }
      let(:search_key) { 'foo.bar.baz' }
      context 'the result' do
        subject { the_result }
        it { should == the_intended_result }
      end
    end

    context 'when getting an existing partial key' do
      context 'the result' do
        let(:search_key) { 'foo.bar' }
        let(:the_intended_result) { source_hash['foo']['bar'] }
        subject { the_result }
        it { should eq the_intended_result }
      end
    end

    context 'when getting a missing key' do
      let(:search_key) { 'fiddle.foodle' }
      context 'the result' do
        subject { the_result }
      end
    end
  end
end
