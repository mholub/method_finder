require 'spec'
require File.join(File.dirname(__FILE__), *%w[method_finder])

describe MethodFinder do
  describe 'Single suggestions' do
    it 'should suggest upcase here' do
      "hello".suggest_method("HELLO").should include("upcase", "swapcase", "upcase!", "swapcase!")
    end
    
    it 'should suggest downcase here' do
      "HELLO".suggest_method("hello").should include("downcase", "swapcase", "downcase!", "swapcase!")
    end
    
    it 'should suggest capitalize here' do
      "hello".suggest_method("Hello").should include ("capitalize", "capitalize!")
    end
    
    it 'should suggest truncate, to_i, to_int, floor' do
      1.5.suggest_method(1).should include("truncate", "to_i", "to_int", "floor")
    end
    
    it 'should suggest round, ceil' do
      1.5.suggest_method(2).should include("round", "ceil")
    end
    
    it "should suggest * and + and **" do
      2.suggest_method(4, 2).should include("*", "+", "**")
    end
  end
  
  describe "Multiply suggestions" do
    it 'should suggest floor' do
      MethodFinder.suggest_method([-1.01, -2], [1.01, 1]).should == 'floor'
    end
    
    it 'should suggest truncate, to_i, to_int, floor' do
      MethodFinder.suggest_method([-1.01, -1], [1.01, 1]).should include("truncate", "to_i", "to_int", "round")
    end
    
    it 'should suggest *' do
      MethodFinder.suggest_method([2, 4, 2], [[2], [2, 2], 2]).should == "*"
    end
  end
end