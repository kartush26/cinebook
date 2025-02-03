class BookingSerializer < Blueprinter::Base
  identifier :id
  fields :reference, :status, :seats_count, :total_amount, :currency,
         :confirmed_at, :cancelled_at, :created_at

  field :show do |b|
    {
      id:        b.show_id,
      starts_at: b.show.starts_at,
      movie:     { id: b.show.movie_id, title: b.show.movie.title },
      theater:   { id: b.show.screen.theater_id, name: b.show.screen.theater.name },
      screen:    { id: b.show.screen_id, name: b.show.screen.name }
    }
  end

  field :seats do |b|
    b.booking_seats.includes(:seat).map { |bs| { id: bs.seat_id, label: "#{bs.seat.row_label}#{bs.seat.column_index}", price: bs.price } }
  end

  view :with_payment do
    field :payment do |b|
      next nil unless b.payment

      {
        provider:      b.payment.provider,
        status:        b.payment.status,
        client_secret: b.payment.client_secret,
        external_id:   b.payment.external_id,
        amount:        b.payment.amount
      }
    end
  end
end
