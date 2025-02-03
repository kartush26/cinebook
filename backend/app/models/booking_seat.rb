class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :seat
  belongs_to :show

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :seat_id, uniqueness: { scope: :show_id, conditions: -> { where(active: true) },
                                    message: 'is already booked for this show' }
end
