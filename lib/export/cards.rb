module Export
  class Cards < Exporter
    def initialize(subtype = %w[earth water fire air void])
      @headers = %w[venue_name venue_effect training_name training_effect duel_name duel_type duel_type\ style duel_text card_back_type card_back_type\ style]

      super "cards.yml" do |cards|
        process(cards, subtype)
      end
    end

    private

    def process(deck, subtype)
      final_cards = []
      deck.slice(*subtype).each do |book_type, cards|
        cards.each do |card|
          card = extrapolate_fields(card)
          card['card_back_type'] = book_type
          card['duel_type style'] = @config['styles'][book_type]['duel_type_style'].map { |s| "{ #{s} }"}.join(' ')
          card['card_back_type style'] = @config['styles'][book_type]['card_back_type_style'].map { |s| "{ #{s} }"}.join(' ')
          final_cards << card
        end
      end

      final_cards
    end

# Converts this:
# [ { venue: { name: "", effect: "" },
#     training: { name: "", effect: "" },
#     duel: { name: "", type: "", text: "" }
#     }, ... } ]
# to:
# { venue_name: '', venue_effect: '', training_name: '', training_effect: '', duel_name: '', duel_type: '', duel_text: '' }
    def extrapolate_fields(card)
      refined_card = {}
      card.each do |mode, fields|
        fields.each do |field, value|
          column = "#{mode}_#{field}"
          refined_card[column] = value
        end
      end

      refined_card
    end
  end
end