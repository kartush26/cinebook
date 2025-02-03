class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.citext  :email,             null: false
      t.string  :name,              null: false
      t.string  :password_digest,   null: false
      t.string  :phone
      t.integer :role,              null: false, default: 0
      t.boolean :active,            null: false, default: true
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
