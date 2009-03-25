require 'set'

module MethodFinder
  
  # finds object selector by example
  # supports only 0-arity methods
  # METHODS_FOR_REJECT = %w[id type clone new initialize dup freeze send taint extend include eval]
  
  def suggest_method(example, *args)
    # filter dangerous methods too
    possible_methods = MethodFinder.methods_by_arity(self, args.length)
    
    find_block = Proc.new do |m|
      begin
        test_object = (self.clone rescue self)
        
        if args.length == 0
          test_object.send(m) == example 
        else
          test_object.send(m, *args) == example
        end
      # methods in C with variable arguments size
      rescue ArgumentError
      # methods with block
      rescue LocalJumpError
      rescue TypeError
      rescue NoMethodError
      end
    end
    
    result = possible_methods.select &find_block
    if result.length < 2
      result.first
    else
      result
    end
  end
  
  # examples is a hash with object -> example pairs
  def self.suggest_method(*examples)
    
    # finds intersection of all suitable methods
    suggested_methods = examples.inject([]) do |methods, example|
      object, result, *args = example
            
      methods << object.suggest_method(result, *args).to_set
    end.inject { |intersection, set| intersection & set }
        
    if suggested_methods.length < 2
      suggested_methods.first
    else
      suggested_methods.to_a
    end
  end
  
  private
  
  def self.methods_by_arity(object, length)
    object_methods = Object.instance_methods
    
    object.methods.reject { |m| (object.method(m).arity != length) || object_methods.include?(m) }
  end
end

class Object
  include MethodFinder
end