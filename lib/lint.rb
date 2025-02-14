require 'bundler/setup'

require 'tty'
require_relative './export'
require 'awesome_print'

module Linter
end

(['./lib/lint/linter.rb'] + Dir.glob("./lib/lint/*.rb")).uniq.each do |linter_path|
  require linter_path
end