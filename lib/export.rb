require 'yaml'
require 'csv'
require_relative 'core'

module Export
  DATA_DIR = "./data"
  EXPORT_DIR = "./export"
end

(['./lib/export/exporter.rb'] + Dir.glob("./lib/export/*.rb")).uniq.each do |exporter_path|
  require exporter_path
end