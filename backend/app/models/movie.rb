class Movie < ApplicationRecord
  enum status: { draft: 0, now_showing: 1, upcoming: 2, archived: 3 }

  has_many :shows,           dependent: :restrict_with_error
  has_many :featured_movies, dependent: :destroy
  has_one_attached  :poster
  has_one_attached  :banner

  validates :title, presence: true, length: { maximum: 200 }
  validates :duration_minutes, numericality: { greater_than: 0, less_than: 600 }
  validates :language, presence: true
  validates :release_date, presence: true
  validates :genres, length: { minimum: 1, message: 'must include at least one genre' }
  validate  :rating_value

  scope :showing,  -> { where(status: :now_showing) }
  scope :search,   ->(q) { where('title ILIKE ?', "%#{sanitize_sql_like(q)}%") if q.present? }
  scope :by_language, ->(l) { where(language: l) if l.present? }
  scope :by_genre,    ->(g) { where('genres && ARRAY[?]::varchar[]', Array(g)) if g.present? }

  def featured_now?
    featured_movies.where('starts_on <= ? AND ends_on >= ?', Time.current, Time.current).exists?
  end

  private

  def rating_value
    return if rating.blank?
    return if %w[U UA A].include?(rating)

    errors.add(:rating, 'must be one of U, UA, A')
  end
end
