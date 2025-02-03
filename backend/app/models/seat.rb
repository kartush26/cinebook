class Seat < ApplicationRecord
  belongs_to :screen
  has_many :booking_seats, dependent: :restrict_with_error

  validates :row_label,    presence: true, length: { maximum: 3 }
  validates :column_index, numericality: { greater_than: 0 }
  validates :category,     inclusion: { in: %w[standard premium recliner] }
  validates :base_price,   numericality: { greater_than_or_equal_to: 0 }

  scope :for_screen, ->(screen_id) { where(screen_id: screen_id) }

  def label
    "#{row_label}#{column_index}"
  end
end
