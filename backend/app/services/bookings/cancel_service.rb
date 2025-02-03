module Bookings
  class CancelService
    def self.call(booking, reason: nil)
      ActiveRecord::Base.transaction do
        booking.lock!
        raise Errors::BookingNotPending, 'Booking cannot be cancelled' unless booking.cancellable?

        booking.booking_seats.update_all(active: false)
        booking.update!(status: :cancelled, cancelled_at: Time.current)

        if booking.payment&.succeeded?
          Payments::Factory.for(booking.payment.provider).refund(payment: booking.payment, reason: reason)
        end
      end

      seat_ids = booking.booking_seats.pluck(:seat_id)
      ActionCable.server.broadcast(
        "seat_channel:#{booking.show_id}",
        { event: 'seat_released', seat_ids: seat_ids }
      )
      booking
    end
  end
end
