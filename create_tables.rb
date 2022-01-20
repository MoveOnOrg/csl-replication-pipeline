#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'byebug'

def normalize_types(type, sql_type)
  if (['enum']).include?(type) || (['hstore', 'json', 'jsonb', 'text']).include?(sql_type) || sql_type.include?('character varying')
    'CHARACTER VARYING(max)'
  elsif %w(uuid).include?(sql_type)
    # https://gist.github.com/wrobstory/4b0ce4e8ba51ec40c494881bc126c003
    'CHAR(36)'
  elsif %w(datetime).include?(type)
    # Redshift timestamp column does not support precision, but some of our newer timestamp columns include it,
    # so normalize on the non-precision version
    'TIMESTAMP WITHOUT TIME ZONE'
  else
    sql_type
  end
end


uri = URI('https://demo.controlshiftlabs.com/api/bulk_data/schema.json')
json = Net::HTTP.get(uri)
tables = JSON.parse(json)['tables']

puts "SET search_path = 'controlshiftdb';"
tables.each do |table|
  name = table['table']['name']
  columns = table['table']['columns']
  column_fields = columns.collect{|col, attrs| "\"#{col}\" #{normalize_types(attrs["type"], attrs["sql_type"])}" }.join(', ')
  puts "DROP TABLE IF EXISTS #{name};"
  puts "CREATE TABLE #{name} (#{column_fields});"
end


