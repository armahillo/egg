require_relative '../core'
require_relative '../shinken_card'

# venue_name      venue_effect
# training_name   training_effect
# duel_name       duel_text         duel_type   duel_type\ style
# card_back_type                                card_back_type\ style]

module Lint
  class Cards < Linter
    EMOJI_MAP = {
      venue: '🗻',
      duel: '⚔️',
      training: '🏋️‍♀️',
      earth: '🌲',
      water: '💧',
      fire: '🔥',
      air: '💨',
      void: '@',
      action: '➡️',
      reaction: '⚡️',
      stance: '🤺',
      technique: '📜',
      weapon: '🗡️'
    }.freeze

    FIELDS = %i[venue_name venue_effect training_name training_effect duel_name duel_type duel_text].freeze

    def initialize(*constraint)
      @constraint = constraint

      exporter = Export::Cards.new
      @metadata = exporter.metadata

      super(cards_data(exporter, %i[duel_types card_names card_effects card_dupes missing_entries]))
    end

    def render(*keys)
      data = keys.empty? ? @data : @data.slice(*keys)
      data.each do |_key, table|
        puts ::TTY::Table::Renderer::Unicode.new(table).render
      end
    end

    private

    def emoji(label)
      EMOJI_MAP[label.downcase.to_sym] || label
    end

    def cards_data(exporter, keys)
      duel_types_data = duel_types.to_h { |book, types| types['status'] = types.values.uniq == ['✅'] ? '✅' : '❌'; [book, types] }
      duel_types_table_data = duel_types_data.keys.zip(duel_types_data.values.map(&:values)).flatten.each_slice(7).to_a
      duel_types_table = ::TTY::Table.new(%w[Card\ Type weapon stance technique action reaction status], duel_types_table_data)

      card_names_data = card_names.sort.tally.map { |card, count| [card, count, card.length] }
      card_names_table = ::TTY::Table.new(%w[Card\ Name count length], card_names_data.to_a)

      tuples_data = tuples
      tuples_table = ::TTY::Table.new(%w[Venue Training Duel], tuples_data.to_a)

      card_effects_data = card_effects.tally.sort.map { |card, count| [card, count, card.length] }
      card_effects_table = ::TTY::Table.new(%w[Card\ Effect count length], card_effects_data.to_a)

      card_dupes_data = card_names_data.collect { |k,v| next unless v > 1; [k,v] }.compact
      card_dupes_table = ::TTY::Table.new(%w[Card\ Name count], card_dupes_data)

      missing_entries_data = missing_entries
      missing_entries_table = ::TTY::Table.new(["<>"] + FIELDS.map(&:to_s), missing_entries_data.map { |r| [r[0]] + r[1..-1].map { |v| v.nil? ? '⚠️' : '✅' } })

      missing_entries_venues_table = ::TTY::Table.new(["<>", 'venue name', 'venue text'], missing_entries_data.map { |r| [r[0]] + r[1..2] })
      missing_entries_training_table = ::TTY::Table.new(["<>", 'training name', 'training text'], missing_entries_data.map { |r| [r[0], r[3]&.truncate(20), r[4]&.truncate(50)] })
      missing_entries_duel_table = ::TTY::Table.new(["<>", 'duel type', 'duel name', 'duel text'], missing_entries_data.map { |r| [r[0], r[6], r[5]&.truncate(20), r[7]&.truncate(50)] })

      {
        duel_types: duel_types_table,
        card_names: card_names_table,
        tuples: tuples_table,
        card_effects: card_effects_table,
        card_dupes: card_dupes_table,
        missing_entries: missing_entries_table,
        missing_entries_venue: missing_entries_venues_table,
        missing_entries_training: missing_entries_training_table,
        missing_entries_duel: missing_entries_duel_table
      }
    end

    def missing_entries
      exporter = Export::Cards.new
      errors = []

      elements = exporter.metadata['linting'].dup.keys
      missing_entries = []

      exporter.cards.collect do |card|
        begin
          field_data = [emoji(card['card_back_type'])]
          field_data += card.slice(*FIELDS.map(&:to_s)).values
          missing_entries << field_data
        rescue NoMethodError => _e
          errors << card
        end
      end

      errors.each do |error|
        p error
      end

      missing_entries
    end

    def card_effects
      exporter = Export::Cards.new
      card_effects = []
      errors = []

      exporter.cards.collect do |card|
        begin
          duel_text = ("#{emoji(:duel)} #{emoji(card['duel_type'].split.first)} | " + card['duel_text']) if card['duel_text']
          training_text = "#{emoji(:training)} #{card['training_effect']}" if card['training_effect']
          venue_text = "#{emoji(:venue)} #{card['venue_effect']}" if card['venue_effect']

          card_effects << (duel_text || "#{emoji(:duel)}? #{emoji(card['duel_type'].split.first)} | #{card['card_back_type']}")
          card_effects << (training_text || "#{emoji(:training)}#{emoji(card['card_back_type'])}? #{card['training_name'].truncate(25)} | #{card['card_back_type']}")
          card_effects << (venue_text || "#{emoji(:venue)}#{emoji(card['card_back_type'])}? #{card['venue_name']&.truncate(25)} | #{card['card_back_type']}")
        rescue NoMethodError => e
          errors << "#{e} #{card}"
        end
      end

      errors.each do |error|
        p error
      end

      card_effects.compact
    end

    def card_names
      exporter = Export::Cards.new
      card_names = []
      errors = []

      exporter.cards.collect do |card|
        begin
          card_names << (card['duel_name'] || "unnamed")
          card_names << (card['training_name'] || "unnamed")
        rescue NoMethodError => _e
          errors << card
        end
      end

      errors.each do |error|
        p error
      end

      card_names.compact
    end

    def tuples
      exporter = Export::Cards.new
      tuples = []
      errors = []

      exporter.cards.collect do |card|
        begin
          tuples << card.slice(*%w[venue_name training_name duel_name]).values
        rescue NoMethodError => _e
          errors << card
        end
      end

      errors.each do |error|
        p error
      end

      tuples.compact
    end

    def duel_types
      exporter = Export::Cards.new
      expected_types = exporter.metadata['linting'].dup

      found_types = expected_types.keys.zip([ [],[],[],[],[] ]).to_h
      errors = []
      exporter.cards.collect do |card|
        begin
          found_types[card['card_back_type']] << Array.wrap(card['duel_type'].downcase.split(/\s?(\||\-)\s?/)).first
        rescue NoMethodError => _e
          errors << card
        end
      end

      errors.each do |error|
        p error
      end

      found_types = found_types.to_h { |book, types| [book, types.tally] }
      type_counts = expected_types.values.first.keys.zip(Array.new(expected_types.keys.size, 0)).to_h

      found_types.transform_values! { |v| type_counts.merge(v) }
      expected_types.merge!(found_types) { |book, expected, found|
        expected.merge(found) { |type, exp_count, fnd_count|
          ((fnd_count || 0) == exp_count) ? "✅" : "#{fnd_count} / #{exp_count}"
        }
      }
    end
  end
end