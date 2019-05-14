require 'rspec/autorun'
require 'byebug'

class ConStruct
  attr_reader :temp, :args

  def initialize(*args)
    @args = args
    check_for_type_error
    @temp = Class.new
    build_class
  end

  private

  def define_initialize(args, size)
    temp.define_method('initialize') do |*values|
      arguments = "(given #{values.size}, expected #{size})"
      error_message = "wrong number of arguments #{arguments}"
      raise ArgumentError, error_message if values.size != size

      values.each_with_index do |value, i|
        instance_variable_set "@#{args[i]}", value
      end
    end
  end

  def check_for_type_error
    error_message = 'only String or Symbol argument types allowed'
    args.each do |arg|
      correct_types = [Symbol, String].any? { |klass| arg.is_a?(klass) }
      raise TypeError, error_message unless correct_types
    end
  end

  def build_class
    define_initialize args, args.size
    define_getters
    define_setters
  end

  def define_getters
    args.each do |arg|
      temp.define_method(arg) { instance_variable_get "@#{arg}" }
    end
  end

  def define_setters
    args.each do |arg|
      temp.define_method("#{arg}=") { |x| instance_variable_set "@#{arg}", x }
    end
  end

  class << self
    def new(*args)
      super(*args).temp
    end
  end
end

describe ConStruct do
  describe '.new' do
    it 'accepts one or more arguements and returns a new Class where those \
      arguments are attribute readers and accessors' do
      Foo = ConStruct.new(:bar, 'buzz')
      foo = Foo.new('Jerry Seinfeld', 54)

      expect(foo.bar).to eq 'Jerry Seinfeld'
      expect(foo.buzz).to eq 54

      foo.bar = Float(42)

      expect(foo.bar).to eq 42.0
    end

    it 'blows up when arguments are not symbols or strings' do
      error_message = 'only String or Symbol argument types allowed'

      expect do
        ConStruct.new(:bar, 'buzz', 8, [1, :vin], duck: 'party')
      end.to raise_error TypeError, error_message
    end

    it 'blows up when there are diferences in amount of arguments' do
      Bar = ConStruct.new(:bar, 'buzz')
      error_message = 'wrong number of arguments (given 4, expected 2)'

      expect do
        Bar.new('Jerry Seinfeld', 54, ['step', :forth], 1337)
      end.to raise_error ArgumentError, error_message
    end
  end
end
