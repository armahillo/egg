require_relative 'core/ext/hash.rb'
require_relative 'core/ext/array.rb'
require_relative 'core/ext/string.rb'

Hash.prepend(Core::Ext::Hash::DeepMerge)
String.prepend(Core::Ext::String::Truncate)
class Array
  extend Core::Ext::Array::Wrap
end
