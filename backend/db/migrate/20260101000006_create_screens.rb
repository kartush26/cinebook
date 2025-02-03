class CreateScreens < ActiveRecord::Migration[7.1]
  def change
    create_table :screens, id: :uuid do |t|
      t.references :theater, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string  :name,    null: false
      t.integer :rows,    null: false
      t.integer :columns, null: false
      t.string  :screen_type, default: 'standard' # standard | imax | 4dx
      t.timestamps
    end
    add_index :screens, %i[theater_id name], unique: true
  end
end
