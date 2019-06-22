require 'rspec/autorun'
require 'byebug'

class Object
  def tap2(&blk)
    raise ArgumentError, 'Missing block' unless block_given?

    instance_eval(&blk)
    self
  end
end

class MyClass
  def initialize
    @var = 'instance var'
  end

  private

  def foo
    'MyClass#foo'
  end
end

describe MyClass do
  describe '#tap2 - Code provided in the block' do
    it 'should have access to instance variables' do
      expect(exec_command_proc).to output("instance var\n").to_stdout
    end

    it "and object's private methods." do
      expect(exec_command).to eq 'MyClass#foo'
    end
  end

  subject { MyClass.new }

  def exec_command
    subject.tap2 { puts @var }.foo
  end

  def exec_command_proc
    method(:exec_command).to_proc
  end
end
