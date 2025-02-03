module Bookings
  # Called by webhook handlers (Stripe / PhonePe) when payment succeeds.
  # Marks the booking confirmed, releases Redis locks, broadcasts on ActionCable,
  # and enqueues post-confirmation jobs (email + QR generation).
  class ConfirmService
    def self.call(booking, payment_external_id: nil)
      ActiveRecord::Base.transaction do
        booking.lock!
        return booking if booking.confirmed?
        raise Errors::BookingNotPending, "Booking #{booking.id} not pending" unless booking.pending?

        booking.update!(status: :confirmed, confirmed_at: Time.current)
        booking.payment&.succeeded! if booking.payment
        booking.payment&.update!(external_id: payment_external_id) if payment_external_id && booking.payment&.external_id.blank?
      end

      seat_ids = booking.booking_seats.pluck(:seat_id)
      ActionCable.server.broadcast(
        "seat_channel:#{booking.show_id}",
        { event: 'seat_booked', seat_ids: seat_ids }
      )

      BookingConfirmationJob.perform_async(booking.id)
      GenerateQrTicketJob.perform_async(booking.id)
      booking
    end
  end
end
