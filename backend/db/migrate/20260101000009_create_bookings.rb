class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :show, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.string  :reference, null: false       # human readable e.g. CB-2X4F9K
      t.integer :status, null: false, default: 0 # pending | confirmed | cancelled | refunded | failed
      t.integer :seats_count, null: false
      t.decimal :total_amount,  null: false, precision: 10, scale: 2
      t.string  :currency, null: false, default: 'USD'
      t.string  :idempotency_key
      t.datetime :confirmed_at
      t.datetime :cancelled_at
      t.timestamps
    end
    add_index :bookings, :reference, unique: true
    add_index :bookings, :status
    add_index :bookings, %i[user_id created_at]
    add_index :bookings, :idempotency_key, unique: true, where: 'idempotency_key IS NOT NULL'
  end
end
