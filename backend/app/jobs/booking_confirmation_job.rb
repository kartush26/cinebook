require 'sidekiq'

class BookingConfirmationJob
  include Sidekiq::Job
  sidekiq_options queue: 'mailers', retry: 5

  def perform(booking_id)
    booking = Booking.includes(:user, booking_seats: :seat, show: { screen: :theater }).find(booking_id)
    BookingMailer.with(booking: booking).confirmation.deliver_now
  end
end
