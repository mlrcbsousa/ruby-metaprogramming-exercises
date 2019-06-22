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

    context 'all in big example' do
      subject do
        proc do
          (1..10)                     .mytap { |x| puts "original: #{x.inspect}" }
            .to_a                     .mytap { |x| puts "array: #{x.inspect}" }
            .select { |x| x % 2 == 0 }.mytap { |x| puts "evens: #{x.inspect}" }
            .map { |x| x * x }        .mytap { |x| puts "squares: #{x.inspect}" }
        end
      end

      it 'inspects every part of the method chain' do
        is_expected.to output(<<~MESSAGE).to_stdout
          original: 1..10
          array: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          evens: [2, 4, 6, 8, 10]
          squares: [4, 16, 36, 64, 100]
        MESSAGE
      end
    end
  end
end
