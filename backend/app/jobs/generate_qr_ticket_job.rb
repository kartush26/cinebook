require 'sidekiq'

class GenerateQrTicketJob
  include Sidekiq::Job
  sidekiq_options queue: 'default', retry: 5

  def perform(booking_id)
    booking = Booking.find(booking_id)
    Qr::TicketService.generate_for(booking)
  end
end
