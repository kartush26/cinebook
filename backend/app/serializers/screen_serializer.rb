class ScreenSerializer < Blueprinter::Base
  identifier :id
  fields :name, :rows, :columns, :screen_type
end
