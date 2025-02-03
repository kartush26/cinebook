require 'blueprinter'

Blueprinter.configure do |config|
  config.generator = Oj
  config.datetime_format = ->(d) { d&.iso8601 }
  config.sort_fields_by = :definition
end
