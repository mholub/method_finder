require 'spec'
require File.join(File.dirname(__FILE__), *%w[method_finder])

describe MethodFinder do
  describe 'Single suggestions' do
    it 'should suggest upcase here' do
      "hello".suggest_method("HELLO").should include("upcase", "swapcase")
    end
    
    it 'should suggest downcase here' do
      "HELLO".suggest_method("hello").should include("downcase", "swapcase")
    end
    
    it 'should suggest capitalize here' do
      "hello".suggest_method("Hello").should == "capitalize"
    end
    
    it 'should suggest truncate, to_i, to_int, floor' do
      1.5.suggest_method(1).should include("truncate", "to_i", "to_int", "floor")
    end
    
    it 'should suggest round, ceil' do
      1.5.suggest_method(2).should include("round", "ceil")
    end
  end
  
  describe "Multiply suggestions" do
    it 'should suggest floor' do
      MethodFinder.suggest_method(-1.01 => -2, 1.01 => 1).should == 'floor'
    end
    
    it 'should suggest truncate, to_i, to_int, floor' do
      MethodFinder.suggest_method(-1.01 => -1, 1.01 => 1).should include("truncate", "to_i", "to_int", "round")
    end
  end
  
  describe 'Internals' do
    it "should not include dangerous methods in zero_arity_methods helper" do
      MethodFinder.send(:zero_arity_methods, "string").should include('upcase', 'downcase')
      MethodFinder.send(:zero_arity_methods, "string").should_not include('upcase!', 'downcase!')
    end
  end
end