class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies, id: :uuid do |t|
      t.string  :title,           null: false
      t.text    :synopsis,        null: false, default: ''
      t.integer :duration_minutes, null: false
      t.string  :language,        null: false
      t.string  :rating           # U/UA/A
      t.string  :genres,          null: false, default: [], array: true
      t.string  :cast,            null: false, default: [], array: true
      t.string  :director
      t.string  :trailer_url
      t.date    :release_date,    null: false
      t.integer :status,          null: false, default: 0 # 0=draft 1=now_showing 2=upcoming 3=archived
      t.decimal :imdb_rating, precision: 3, scale: 1
      t.timestamps
    end
    add_index :movies, :title
    add_index :movies, :status
    add_index :movies, :language
    add_index :movies, :release_date
    add_index :movies, :genres, using: 'gin'
  end
end
