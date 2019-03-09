#!/usr/bin/env ruby

require 'json'
require 'HTTParty'
require 'smarter_csv'
require 'logger'
require 'colorize'

# Usage:
# ./csv2geojson.rb #{csv_file}

$stdout.sync = true
Dir.chdir(File.dirname(__FILE__))

$land_properties = [:"縣市", :"段", :"小段", :"地號"]

module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new('logs/csv2geojson.log')
  end
end

def write_json(data, file=nil)
  unless file
    file = 'output/output.geojson'
  end
  File.write(file, JSON.pretty_generate(data))
end

def get_gps(lands_list)
  params = { "lands" => lands_list }
  url = "http://twland.ronny.tw/index/search"
  response = HTTParty.get(url, :query => params)
  #result = JSON.parse(response.body)
  return response.body
end

def get_feature(data)
  # puts data
  if data[:"小段"] && data[:"小段"].to_s != ""
    land = [data[:"縣市"], "#{data[:"段"]}#{data[:"小段"]}", data[:"地號"]].join(',')
  else
    land = [data[:"縣市"], "#{data[:"段"]}", data[:"地號"]].join(',')
  end
  Logging.logger.info land
  params = { "lands[]" => land }
  url = "http://twland.ronny.tw/index/search"
  response = HTTParty.get(url, :query => params)
  geojson = JSON.parse(response.body)
  Logging.logger.info geojson
  feature = geojson["features"].first
  if feature == nil
    print '.'.red
    return false
  end
  feature["properties"] = {}
  data.keys.each do |k|
    unless $land_properties.include? k
      feature["properties"][k] = data[k]
    end
  end
  print '.'.green
  return feature
end

def main
  input = ARGV[0]
  estate_data = SmarterCSV.process(input)

  result_geojson = {
    "type" => "FeatureCollection",
    "features" => []
  }

  estate_data.each do |estate|
    feature = get_feature(estate)
    if feature
      result_geojson["features"] << feature
    end
  end
  write_json(result_geojson)
  puts "\n"
end

main()
