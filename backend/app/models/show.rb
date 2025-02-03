class Show < ApplicationRecord
  enum status: { scheduled: 0, cancelled: 1, completed: 2 }

  belongs_to :movie
  belongs_to :screen
  has_one :theater, through: :screen
  has_many :seats, through: :screen
  has_many :booking_seats, dependent: :restrict_with_error
  has_many :bookings, dependent: :restrict_with_error

  validates :starts_at, :ends_at, presence: true
  validate  :ends_after_starts
  validate  :no_overlap_on_screen

  scope :upcoming, -> { where('starts_at >= ?', Time.current).where(status: :scheduled) }
  scope :for_movie, ->(movie_id) { where(movie_id: movie_id) if movie_id.present? }
  scope :for_theater, ->(theater_id) {
    if theater_id.present?
      joins(:screen).where(screens: { theater_id: theater_id })
    end
  }
  scope :on_date, ->(date) {
    if date.present?
      d = date.is_a?(Date) ? date : Date.parse(date.to_s)
      where(starts_at: d.beginning_of_day..d.end_of_day)
    end
  }

  def price_for(seat)
    (seat.base_price * price_multiplier).round(2)
  end

  def booked_seat_ids
    booking_seats.where(active: true).pluck(:seat_id)
  end

  private

  def ends_after_starts
    return if ends_at.blank? || starts_at.blank?

    errors.add(:ends_at, 'must be after starts_at') if ends_at <= starts_at
  end

  def no_overlap_on_screen
    return if starts_at.blank? || ends_at.blank? || screen_id.blank?

    overlap = Show.where(screen_id: screen_id)
                  .where.not(id: id)
                  .where('starts_at < ? AND ends_at > ?', ends_at, starts_at)
    errors.add(:base, 'overlaps with another show on the same screen') if overlap.exists?
  end
end
