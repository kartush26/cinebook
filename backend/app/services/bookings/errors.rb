module Bookings
  module Errors
    class SeatUnavailable < StandardError
      attr_reader :seat_ids
      def initialize(message = 'One or more seats are unavailable', seat_ids: [])
        super(message)
        @seat_ids = seat_ids
      end
    end

    class LockExpired       < StandardError; end
    class InvalidLockToken  < StandardError; end
    class BookingNotPending < StandardError; end
  end
end
