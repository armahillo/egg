require_relative '../lib/export'

RSpec.describe "Example" do
  EXAMPLE_EXPORT = Export::Example.new

  describe "Card group 1" do
    it "correctly observes the prevalence of each species" do
      card_count = EXAMPLE_EXPORT.cards.collect { |ex| ex['name'] }.tally.sort_by(&:last).reverse.to_h

      expect(card_count).not_to be_empty
    end
  end
end