module Lint
  class Linter
    include Enumerable

    attr_reader :data

    def initialize(collection = {}, opts = {})
      @data = collection
      @options = { headers: { name: "Name" } }.merge(opts)
    end

    def constrain(*fields)
      @data = fields.any? ? @data.slice(*fields) : @data
      self
    end

    def render(opts: {})
      opts = @options.merge(opts)
      headers = opts[:headers][:name].ljust(@options.dig(:widths,:name) || 0) + "\t\t"

      @data.keys.each do |column|
        headers += "#{column}".ljust(@options.dig(:widths, column.to_sym) || 0) + "\t"
      end

      puts headers
      puts "-" * headers.gsub("\t", "    ").size

      (@data.values.map(&:keys).flatten.uniq).each do |row_key|
        print "#{row_key.ljust(@options[:widths][:name])}\t\t"

        @data.keys.each do |column|
          print @data[column][row_key].to_s.ljust(@options.dig(:widths, column.to_sym) || 0) + "\t"
        end

        puts ''
      end
    end

    def each
      yield(@collection)
    end

    protected

    def tally_and_rank(list)
      list.tally.sort_by(&:last).reverse.to_h
    end

    def tally(collection, &_block)
      tally_and_rank(collection.cards.collect { |card|
        yield(card)
      })
    end

    def gather(collection, keys, &_block)
      output = keys.zip(Array.new(keys.size)).to_h

      collection.cards.collect { |card|
        traits_hash = yield(card)
        output.merge!(traits_hash) { |k, v1, v2|
          (v1 || []) << v2
        }
      }

      output
    end
  end
end