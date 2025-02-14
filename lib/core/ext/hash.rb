module Core
  module Ext
    module Hash
      module DeepMerge
        def deep_merge(other_hash, &block)
          dup.deep_merge!(other_hash, &block)
        end

        def deep_merge!(other_hash, &block)
          merge!(other_hash) do |key, this_val, other_val|
            if this_val.class.name == "Hash" && other_val.class.name == "Hash"
              this_val.deep_merge(other_val, &block)
            elsif block_given?
              block.call(key, this_val, other_val)
            else
              other_val
            end
          end
        end
      end
    end
  end
end