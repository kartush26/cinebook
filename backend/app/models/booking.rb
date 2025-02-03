class Booking < ApplicationRecord
  enum status: { pending: 0, confirmed: 1, cancelled: 2, refunded: 3, failed: 4 }

  belongs_to :user
  belongs_to :show
  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats
  has_one  :payment, dependent: :destroy

  before_validation :generate_reference, on: :create

  validates :reference, presence: true, uniqueness: true
  validates :total_amount, numericality: { greater_than: 0 }
  validates :seats_count,  numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }

  def cancellable?
    pending? || (confirmed? && show.starts_at > 2.hours.from_now)
  end

  private

  def generate_reference
    return if reference.present?

    loop do
      candidate = "CB-#{SecureRandom.alphanumeric(8).upcase}"
      break (self.reference = candidate) unless Booking.exists?(reference: candidate)
    end
  end
end
