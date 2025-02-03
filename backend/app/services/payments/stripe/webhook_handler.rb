module Payments
  module Stripe
    class WebhookHandler
      def initialize(event)
        @event = event
      end

      def process
        case @event['type']
        when 'payment_intent.succeeded'
          on_succeeded(@event['data']['object'])
        when 'payment_intent.payment_failed'
          on_failed(@event['data']['object'])
        when 'charge.refunded'
          on_refunded(@event['data']['object'])
        else
          Rails.logger.info("[stripe webhook] ignored event #{@event['type']}")
        end
      end

      private

      def on_succeeded(intent)
        booking = locate_booking(intent)
        return unless booking

        ::Bookings::ConfirmService.call(booking, payment_external_id: intent['id'])
      end

      def on_failed(intent)
        booking = locate_booking(intent)
        return unless booking

        ActiveRecord::Base.transaction do
          booking.payment&.update!(status: :failed,
                                   raw_payload: booking.payment.raw_payload.merge('failure' => intent))
          booking.booking_seats.update_all(active: false)
          booking.update!(status: :failed)
        end
        ActionCable.server.broadcast(
          "seat_channel:#{booking.show_id}",
          { event: 'seat_released', seat_ids: booking.booking_seats.pluck(:seat_id) }
        )
      end

      def on_refunded(charge)
        payment = ::Payment.find_by(external_id: charge['payment_intent'])
        payment&.refunded!
      end

      def locate_booking(intent)
        booking_id = intent.dig('metadata', 'booking_id')
        ::Booking.find_by(id: booking_id) ||
          ::Booking.joins(:payment).find_by(payments: { external_id: intent['id'] })
      end
    end
  end
end
