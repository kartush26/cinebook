class WebhookEvent < ApplicationRecord
  enum status: { received: 0, processed: 1, failed: 2 }

  validates :provider, :external_id, :event_type, presence: true
  validates :external_id, uniqueness: { scope: :provider }

  def mark_processed!
    update!(status: :processed, processed_at: Time.current, error: nil)
  end

  def mark_failed!(err)
    update!(status: :failed, error: err.to_s[0, 1_000])
  end
end
