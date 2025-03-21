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
require 'rake/notes/rake_task'


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
    ].each do |asset|
      `rake export:#{asset} > ./export/#{asset}.csv`
    end
  end

  # desc "Asset name"
  # task :asset_name => :setup do
    # puts Export::Cards.new('asset_name').to_csv
  #end
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
  end
end