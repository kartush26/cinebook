require 'sidekiq'

# Defensive job — if Stripe webhook is delayed/missed, we still find pending
# bookings older than 10 minutes and pull their status directly.
class PaymentReconciliationJob
  include Sidekiq::Job
  sidekiq_options queue: 'low', retry: 3

  def perform
    Payment.where(status: :initiated).where('created_at < ?', 10.minutes.ago).find_each do |payment|
      next unless payment.provider == 'stripe' && payment.external_id.present?

      intent = ::Stripe::PaymentIntent.retrieve(payment.external_id)
      case intent.status
      when 'succeeded'
        Bookings::ConfirmService.call(payment.booking, payment_external_id: intent.id)
      when 'canceled', 'requires_payment_method'
        payment.update!(status: :failed)
        Bookings::CancelService.call(payment.booking) if payment.booking.pending?
      end
    rescue StandardError => e
      Rails.logger.error("[reconciliation] payment=#{payment.id}: #{e.message}")
    end
  end
end
