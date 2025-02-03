module Qr
  class TicketService
    def self.generate_for(booking)
      payload = {
        booking_id:        booking.id,
        reference:         booking.reference,
        show_id:           booking.show_id,
        seats:             booking.booking_seats.includes(:seat).map { |bs| "#{bs.seat.row_label}#{bs.seat.column_index}" },
        confirmed_at:      booking.confirmed_at&.iso8601,
        signature:         signature_for(booking)
      }.to_json

      png = RQRCode::QRCode.new(payload).as_png(size: 480, border_modules: 2)
      io  = StringIO.new(png.to_s)

      booking.update!(updated_at: Time.current)
      ActiveStorage::Blob.create_and_upload!(
        io:           io,
        filename:     "ticket-#{booking.reference}.png",
        content_type: 'image/png'
      ).tap do |blob|
        booking.payment&.update!(raw_payload: booking.payment.raw_payload.merge('qr_blob_id' => blob.id))
      end
    end

    def self.signature_for(booking)
      Digest::SHA256.hexdigest("#{booking.id}|#{booking.reference}|#{ENV.fetch('JWT_SECRET')}")
    end
  end
end
