class Theater < ApplicationRecord
  has_many :screens, dependent: :destroy
  has_many :shows, through: :screens

  validates :name, presence: true, length: { maximum: 120 }
  validates :city, presence: true
  validates :address, presence: true

  scope :active, -> { where(active: true) }
  scope :in_city, ->(city) { where('LOWER(city) = ?', city.to_s.downcase) if city.present? }
end
