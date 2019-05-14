require 'rspec/autorun'
require 'byebug'

class ConStruct
  def initialize(*args)
    @args = args
    set_args
    Object.const_set 'SIZE', args.size
    Object.const_set 'ARGS', args
    @temp = Class.new
    build_class
  end

  private

  def set_args
    @args.each do |arg|
      error_message = 'only String or Symbol argument types allowed'
      correct_types = [Symbol, String].map { |klass| arg.is_a?(klass) }.any?
      raise TypeError, error_message unless correct_types

      Object.const_set arg.upcase, arg
    end
  end

  def build_class
    define_initialize
    define_getters
    define_setters
  end

  def define_initialize
    @temp.define_method('initialize') do |*args|
      arguments = "(given #{args.size}, expected #{SIZE})"
      error_message = "wrong number of arguments #{arguments}"
      raise ArgumentError, error_message if args.size != SIZE

      args.each_with_index { |arg, i| instance_variable_set "@#{ARGS[i]}", arg }
    end
  end

  def define_getters
    ARGS.each do |arg|
      @temp.define_method(arg) { instance_variable_get "@#{arg}" }
    end
  end

  def define_setters
    ARGS.each do |arg|
      @temp.define_method("#{arg}=") { |x| instance_variable_set "@#{arg}", x }
    end
  end

  def return_class
    # Object.send(:remove_const, 'SIZE')
    # Object.send(:remove_const, 'ARGS')
    # @args.each { |arg| Object.send(:remove_const, arg.upcase) }
    @temp
  end

  class << self
    def new(*args)
      super(*args).send 'return_class'
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
      Foo = ConStruct.new(:bar, 'buzz')
      error_message = 'wrong number of arguments (given 4, expected 2)'

      expect do
        Foo.new('Jerry Seinfeld', 54, ['step', :forth], 1337)
      end.to raise_error ArgumentError, error_message
    end
  end
end
