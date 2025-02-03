class Screen < ApplicationRecord
  belongs_to :theater
  has_many :seats, dependent: :destroy
  has_many :shows, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :theater_id, case_sensitive: false }
  validates :rows, :columns, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :screen_type, inclusion: { in: %w[standard imax 4dx dolby] }

  def total_capacity
    rows * columns
  end
end
