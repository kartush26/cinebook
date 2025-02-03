class User < ApplicationRecord
  has_secure_password

  enum role: { customer: 0, admin: 1 }

  has_many :bookings,        dependent: :restrict_with_error
  has_many :refresh_tokens,  dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name,  presence: true, length: { maximum: 80 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :phone, format: { with: /\A\+?[0-9\-\s]{7,15}\z/ }, allow_blank: true

  normalizes :email, with: ->(v) { v.to_s.strip.downcase }

  scope :active, -> { where(active: true) }
end
