module Payments
  module Stripe
    class Provider < Payments::Base
      WEBHOOK_SECRET = -> { ENV.fetch('STRIPE_WEBHOOK_SECRET') }

      def create_intent(booking:, idempotency_key:)
        amount_cents = (booking.total_amount * 100).to_i

        intent = ::Stripe::PaymentIntent.create(
          {
            amount:                amount_cents,
            currency:              booking.currency.downcase,
            payment_method_types:  %w[card],
            metadata: {
              booking_id:        booking.id,
              booking_reference: booking.reference,
              user_id:           booking.user_id
            },
            description: "CineBook ##{booking.reference}"
          },
          { idempotency_key: idempotency_key }
        )

        ::Payment.create!(
          booking:         booking,
          provider:        'stripe',
          external_id:     intent.id,
          client_secret:   intent.client_secret,
          status:          :initiated,
          amount:          booking.total_amount,
          currency:        booking.currency,
          idempotency_key: idempotency_key,
          raw_payload:     intent.to_hash
        )
      end

      def refund(payment:, reason: nil)
        refund = ::Stripe::Refund.create(
          payment_intent: payment.external_id,
          reason:         reason.presence || 'requested_by_customer'
        )
        payment.update!(status: :refunded, refunded_at: Time.current,
                        raw_payload: payment.raw_payload.merge('refund' => refund.to_hash))
        payment
      end

      def verify_webhook(payload:, signature:)
        ::Stripe::Webhook.construct_event(payload, signature, WEBHOOK_SECRET.call)
      rescue ::Stripe::SignatureVerificationError => e
        raise SecurityError, "Invalid Stripe signature: #{e.message}"
      end

      def handle_event(event)
        WebhookHandler.new(event).process
      end
    end
  end
end
