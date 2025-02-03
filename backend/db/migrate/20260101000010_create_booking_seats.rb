class CreateBookingSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :booking_seats, id: :uuid do |t|
      t.references :booking, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :seat,    type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :show,    type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.decimal  :price, null: false, precision: 8, scale: 2
      t.boolean  :active, null: false, default: true
      t.timestamps
    end

    # Truth-of-record uniqueness — one active booking per (show, seat)
    add_index :booking_seats, %i[show_id seat_id],
              unique: true, where: 'active = true', name: 'uniq_active_booking_seat'
  end
end
