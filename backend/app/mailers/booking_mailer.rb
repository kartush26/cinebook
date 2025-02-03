class BookingMailer < ApplicationMailer
  def confirmation
    @booking = params[:booking]
    mail to: @booking.user.email, subject: "🎬 Your CineBook booking ##{@booking.reference} is confirmed"
  end
end
