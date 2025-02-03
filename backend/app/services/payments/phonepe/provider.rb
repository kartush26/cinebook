module Payments
  module Phonepe
    # Functional stub conforming to the Payments::Base contract.
    # Wire up real PhonePe API calls (Standard Checkout) here.
    class Provider < Payments::Base
      def create_intent(booking:, idempotency_key:)
        ::Payment.create!(
          booking:         booking,
          provider:        'phonepe',
          external_id:     "PP-#{SecureRandom.hex(10)}",
          client_secret:   nil,
          status:          :initiated,
          amount:          booking.total_amount,
          currency:        booking.currency,
          idempotency_key: idempotency_key,
          raw_payload:     { provider: 'phonepe', note: 'PhonePe stub' }
        )
      end

      def refund(payment:, reason: nil)
        payment.refunded!
        payment
      end

      def verify_webhook(payload:, signature:)
        # In real impl: compute SHA256(payload + salt_key) and compare.
        raise SecurityError, 'Invalid PhonePe signature' if signature.blank?

        JSON.parse(payload)
      end

      def handle_event(event)
        WebhookHandler.new(event).process
      end
    end
  end
end
