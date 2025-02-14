module Core
  module Ext
    module String
      module Truncate
        def truncate(limit)
          if self.length > limit
            self[0..limit] + "..."
          else
            self
          end
        end
      end
    end
  end
end