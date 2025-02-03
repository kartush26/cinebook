class CreateTheaters < ActiveRecord::Migration[7.1]
  def change
    create_table :theaters, id: :uuid do |t|
      t.string :name,     null: false
      t.string :city,     null: false
      t.string :address,  null: false
      t.decimal :latitude,  precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.boolean :active,  null: false, default: true
      t.timestamps
    end
    add_index :theaters, %i[city name]
    add_index :theaters, :active
  end
end
