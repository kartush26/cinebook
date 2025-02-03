class CreateShows < ActiveRecord::Migration[7.1]
  def change
    create_table :shows, id: :uuid do |t|
      t.references :movie,  type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :screen, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.datetime :starts_at, null: false
      t.datetime :ends_at,   null: false
      t.decimal  :price_multiplier, null: false, default: 1.0, precision: 4, scale: 2
      t.integer  :status, null: false, default: 0 # scheduled | cancelled | completed
      t.string   :language
      t.timestamps
    end
    add_index :shows, %i[screen_id starts_at]
    add_index :shows, %i[movie_id starts_at]
    add_index :shows, :starts_at
    # Prevent overlapping shows on same screen — checked in app layer + this helper index
  end
end
