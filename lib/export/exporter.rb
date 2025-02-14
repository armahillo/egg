# frozen_string: true

# Don't Modify this.

module Export
  class Exporter
    attr_reader :cards, :config, :metadata

    METADATA_FIELDS = %w[version]

    def initialize(filename, &block)
      @source_file = "#{DATA_DIR}/#{filename}"

      @data = YAML.load_file(@source_file, aliases: true)
      @export_file = "#{EXPORT_DIR}/#{filename.gsub(/yml/,'csv')}"

      preprocess_cards

      @cards = block_given? ? yield(@cards) : @cards
      @headers += METADATA_FIELDS

      postprocess_cards
    end

    def to_csv
      output = CSV.generate do |csv|
        csv << @headers

        @cards.each do |record|
          # Any preparation or preprocessing can be done in the block
          # of the subclass.
          record = yield(record) if block_given?

          row = []

          # The list of headers must match the record keys exactly.
          @headers.each do |header|
            row << record[header]
          end

          csv << row
        end

        csv.to_s
      end
    end

    def preprocess_cards
      @config = @data.delete('config')
      @metadata = @data.delete('metadata')
      @cards = @data.delete('cards') || @data
    rescue => e
      require 'pry-nav'; binding.pry
    end

    def postprocess_cards
      @cards.map! do |card|
        METADATA_FIELDS.each do |metadatum|
          card[metadatum] = @metadata[metadatum]
        end

        card
      end
    rescue => e
      require 'pry-nav'; binding.pry
    end
  end
end