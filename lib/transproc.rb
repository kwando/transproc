require 'transproc/version'
require 'transproc/function'
require 'transproc/composer'
require 'transproc/error'

module Transproc
  module_function

  # Register a new function
  #
  # @example
  #   Transproc.register(:to_json, -> v { v.to_json })
  #
  #   Transproc(:map_array, Transproc(:to_json))
  #
  #
  # @return [Function]
  #
  # @api public
  def register(*args, &block)
    name, fn = *args
    raise Error.new("function #{name} is already defined") if functions.include?(name)
    functions[name] = fn || block
  end

  # Get registered function with provided name
  #
  # @param [Symbol] name The name of the registered function
  #
  # @api private
  def [](name)
    functions[name] or raise Error.new("no registered function for #{name}")
  end

  # Function registry
  #
  # @api private
  def functions
    @_functions ||= {}
  end

  # Function container extension
  #
  # @example
  #   module MyTransformations
  #     extend Transproc::Functions
  #
  #     def boom!(value)
  #       "#{value} BOOM!"
  #     end
  #   end
  #
  #   Transproc(:boom!)['w00t!'] # => "w00t! BOOM!"
  #
  # @api public
  module Functions
    def method_added(meth)
      module_function meth
      Transproc.register(meth, method(meth))
    end
  end
end

# Access registered functions
#
# @example
#   Transproc(:map_array, Transproc(:to_string))
#
#   Transproc(:to_string) >> Transproc(-> v { v.upcase })
#
# @param [Symbol,Proc] fn The name of the registered function or an anonymous proc
# @param [Array] args Optional addition args that a given function may need
#
# @return [Function]
#
# @api public
def Transproc(fn, *args)
  case fn
  when Proc then Transproc::Function.new(fn, args: args)
  when Symbol then Transproc::Function.new(Transproc[fn], args: args)
  end
end
