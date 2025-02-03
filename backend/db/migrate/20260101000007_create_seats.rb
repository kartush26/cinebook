class CreateSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :seats, id: :uuid do |t|
      t.references :screen, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string  :row_label,    null: false  # "A", "B" ...
      t.integer :column_index, null: false
      t.string  :category,     null: false, default: 'standard' # standard | premium | recliner
      t.decimal :base_price,   null: false, precision: 8, scale: 2
      t.timestamps
    end
    add_index :seats, %i[screen_id row_label column_index], unique: true
    add_index :seats, :category
  end
end
