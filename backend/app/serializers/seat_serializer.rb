class SeatSerializer < Blueprinter::Base
  identifier :id
  fields :row_label, :column_index, :category, :base_price
  field :label do |seat|
    "#{seat.row_label}#{seat.column_index}"
  end
end
