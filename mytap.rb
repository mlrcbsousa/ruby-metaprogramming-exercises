require 'rspec/autorun'
require 'byebug'

class Object
  def mytap
    raise ArgumentError, 'Missing block' unless block_given?

    yield(self)
    self
  end
end

describe Object do
  describe '#mytap' do
    let(:some_object) { 3 }

    context 'when no block given' do
      subject { proc { some_object.mytap } }

      it 'should raise no block given error' do
        is_expected.to raise_error ArgumentError, 'Missing block'
      end
    end

    context 'when block given' do
      subject { some_object.mytap { |arg| arg * arg } }

      it 'accepts a block with self as an argument to the block \
          runs the block and returns self' do
        is_expected.to eq 3
      end

      context 'change some_object to 5' do
        let(:some_object) { 5 }

        it { is_expected.to eq 5 }
      end

      context 'print string in block' do
        subject { some_object.mytap { |_arg| print 'some string' } }

        it 'should return self after printing string' do
          is_expected.to eq 3
        end
      end

      context 'can change self' do
        subject { {}.mytap { |arg| arg[:key] = 2 } }

        it { is_expected.to eq(key: 2) }
      end
    end
  end
end
