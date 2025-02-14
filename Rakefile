#!/usr/bin/env ruby

# task :default => :test
module Gem
  # This is necessary for TTY functions in linting.
  module_function
  def gunzip(*args)
    Gem::Util.gunzip(*args)
  end
end

require 'bundler/setup'
require 'rspec/core/rake_task'
require './lib/core'

desc "Run tests"
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

desc "Render rules"
task :rules do
  require 'github/markup'

  rules_text = GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, File.read('doc/rules.md'))
  layout = File.read('export/rules_layout.html')
  puts layout.gsub('CONTENTS', rules_text)
end

namespace :export do
  task :setup do
    require_relative './lib/export'
  end

  desc "All"
  task :all => :setup do
    %w[
      earth
      water
      fire
      air
      void
    ].each do |asset|
      #puts "rake export:#{asset} > ./export/#{asset}.csv"
      `rake export:#{asset} > ./export/#{asset}.csv`
    end
  end

  desc "Earth"
  task :earth => :setup do
    puts Export::Cards.new('earth').to_csv
  end

  desc "Air"
  task :air => :setup do
    puts Export::Cards.new('air').to_csv
  end

  desc "Water"
  task :water => :setup do
    puts Export::Cards.new('water').to_csv
  end

  desc "fire"
  task :fire => :setup do
    puts Export::Cards.new('fire').to_csv
  end

  desc "void"
  task :void => :setup do
    puts Export::Cards.new('void').to_csv
  end
end

namespace :lint do
  task :setup do
    require_relative './lib/lint'
  end

  namespace :cards do
    task :load => :setup do
      @cards = Lint::Cards.new
    end

    desc "Cards [all]"
    task :all => :load do
      @cards.render
    end

    desc "Card metrics [duel_type]"
    task :duel_types => :load do
      @cards.render(:duel_types)
    end

    desc "Card names, sorted"
    task :names => :load do
      @cards.render(:card_names)
    end

    desc "Names, grouped"
    task :tuples => :load do
      @cards.render(:tuples)
    end


    desc "Card effects, sorted"
    task :effects => :load do
      @cards.render(:card_effects)
    end

    desc "Card names, repeats"
    task :dupes => :load do
      @cards.render(:card_dupes)
    end

    desc "Missing entries"
    task :missing => :load do
      @cards.render(:missing_entries)
    end

    namespace :summary do
      task :venue => :load do
        @cards.render(:missing_entries_venue)
      end

      task :training => :load do
        @cards.render(:missing_entries_training)
      end

      task :duel => :load do
        @cards.render(:missing_entries_duel)
      end
    end
  end
end