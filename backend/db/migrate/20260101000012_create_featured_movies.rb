class CreateFeaturedMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :featured_movies, id: :uuid do |t|
      t.references :movie, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :position, null: false  # 1..4
      t.datetime :starts_on, null: false
      t.datetime :ends_on,   null: false
      t.timestamps
    end
    add_index :featured_movies, %i[position starts_on], unique: true
    add_index :featured_movies, :ends_on
  end
end
