module Bookings
  # Creates a `pending` Booking + `BookingSeat`s + a payment intent in a single
  # transaction. Uses row-level locks and a unique partial index as the final
  # source of truth — Redis lock is a UX layer.
  class CreateService
    Result = Struct.new(:booking, :payment, keyword_init: true)

    def initialize(user:, show_id:, seat_ids:, lock_token:, payment_provider: 'stripe', idempotency_key: nil)
      @user             = user
      @show_id          = show_id
      @seat_ids         = Array(seat_ids).map(&:to_s).uniq
      @lock_token       = lock_token
      @payment_provider = payment_provider
      @idempotency_key  = idempotency_key.presence || SecureRandom.uuid
    end

    def call
      # Idempotency — return the existing booking instead of double-creating.
      if (existing = ::Booking.find_by(idempotency_key: @idempotency_key))
        return Result.new(booking: existing, payment: existing.payment)
      end

      verify_lock!
      booking = nil
      payment = nil

      ActiveRecord::Base.transaction do
        show = ::Show.lock.find(@show_id)
        raise Errors::SeatUnavailable, 'Show is no longer open for booking' unless show.scheduled?
        raise Errors::SeatUnavailable, 'Show has already started' if show.starts_at <= Time.current

        seats = ::Seat.lock.where(id: @seat_ids).to_a
        raise ActiveRecord::RecordNotFound, 'Seat(s) not found' if seats.length != @seat_ids.size
        raise Errors::SeatUnavailable, 'Seats do not belong to this show screen' if seats.map(&:screen_id).uniq != [show.screen_id]

        already = ::BookingSeat.where(active: true, show_id: show.id, seat_id: @seat_ids).pluck(:seat_id)
        raise Errors::SeatUnavailable.new(seat_ids: already) if already.any?

        total = seats.sum { |s| show.price_for(s) }

        booking = ::Booking.create!(
          user:           @user,
          show:           show,
          status:         :pending,
          seats_count:    seats.size,
          total_amount:   total,
          currency:       'USD',
          idempotency_key: @idempotency_key
        )

        booking_seat_rows = seats.map do |s|
          {
            id:         SecureRandom.uuid,
            booking_id: booking.id,
            seat_id:    s.id,
            show_id:    show.id,
            price:      show.price_for(s),
            active:     true,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        ::BookingSeat.insert_all!(booking_seat_rows)

        payment = Payments::Factory.for(@payment_provider).create_intent(
          booking: booking,
          idempotency_key: @idempotency_key
        )
      end

      Result.new(booking: booking.reload, payment: payment)
    rescue ActiveRecord::RecordNotUnique
      raise Errors::SeatUnavailable, 'A concurrent booking already secured one of these seats'
    end

    private

    def verify_lock!
      SeatLockService.verify!(show_id: @show_id, seat_ids: @seat_ids,
                              user_id: @user.id, lock_token: @lock_token)
    end
  end
end
