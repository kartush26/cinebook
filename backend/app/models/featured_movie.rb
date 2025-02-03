class FeaturedMovie < ApplicationRecord
  belongs_to :movie

  validates :position, presence: true, inclusion: { in: 1..4 }
  validates :starts_on, :ends_on, presence: true
  validate  :ends_after_starts

  scope :current, -> { where('starts_on <= :now AND ends_on >= :now', now: Time.current).order(:position) }

  private

  def ends_after_starts
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, 'must be after starts_on') if ends_on <= starts_on
  end
end
