class Payment < ApplicationRecord
  enum status: { initiated: 0, requires_action: 1, succeeded: 2, failed: 3, refunded: 4 }

  belongs_to :booking

  validates :provider, presence: true, inclusion: { in: %w[stripe phonepe] }
  validates :amount, numericality: { greater_than: 0 }
  validates :idempotency_key, presence: true, uniqueness: true

  def succeeded!
    update!(status: :succeeded, paid_at: Time.current)
  end

  def refunded!
    update!(status: :refunded, refunded_at: Time.current)
  end
end
