require 'set'

module MethodFinder
  
  # finds object selector by example
  # supports only 0-arity methods
  # METHODS_FOR_REJECT = %w[id type clone new initialize dup freeze send taint extend include eval]
  
  def suggest_method(example, all = false)
    # filter dangerous methods too
    zero_arity_methods = MethodFinder.zero_arity_methods(self)
    
    find_block = Proc.new do |m|
      begin
        self.send(m) == example 
        
      # methods in C with variable arguments size
      rescue ArgumentError
      # methods with block
      rescue LocalJumpError
      end
    end
    
    unless all
      zero_arity_methods.find &find_block
    else
      zero_arity_methods.select &find_block
    end
  end
  
  # examples is a hash with object -> example pairs
  def self.suggest_method(examples, all = false)
    
    # finds intersection of all suitable methods
    suggested_methods = examples.inject([]) do |methods, pair|
      object, example = pair
            
      methods << object.suggest_method(example, :all).to_set
    end.inject { |intersection, set| intersection & set }
        
    unless all
      suggested_methods.first
    else
      suggested_methods.to_a
    end
  end
  
  private
  
  def self.zero_arity_methods(object)
    object_methods = Object.instance_methods
    
    zero_arity_methods = object.methods.reject { |m| m["!"] || (object.method(m).arity > 0) || object_methods.include?(m) }
  end
end

class Object
  include MethodFinder
end