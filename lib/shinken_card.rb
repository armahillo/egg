require_relative './core/card'

module Shinken
  class Card < ::Card
    TYPES = %w[earth water fire air void]

    def id
      "#{@card_back_type[0]}#{@duel_type}"
    end

    def <=>(other)
      TYPES.index[@card_back_type] <=> TYPES.index[other.card_back_type]
    end
  end
end