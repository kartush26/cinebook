require 'rails_helper'

RSpec.describe 'Bookings', type: :request do
  let(:user)   { create(:user) }
  let(:screen) { create(:screen, rows: 1, columns: 3) }
  let!(:seats) { (1..3).map { |i| create(:seat, screen: screen, row_label: 'A', column_index: i) } }
  let(:show)   { create(:show, screen: screen) }

  before do
    allow(Stripe::PaymentIntent).to receive(:create).and_return(
      Struct.new(:id, :client_secret).new('pi_x', 'cs_x').tap { |s| def s.to_hash; { id: id }; end }
    )
  end

  it 'goes end-to-end: lock → create → confirm' do
    allow(Bookings::SeatLockService).to receive(:lock!).and_return(
      Bookings::SeatLockService::Result.new(
        lock_token: 'token-123',
        expires_at: 5.minutes.from_now,
        show_id: show.id,
        seat_ids: [seats[0].id, seats[1].id]
      )
    )

    allow(Bookings::SeatLockService).to receive(:verify!).and_return(true)

    post "/api/v1/shows/#{show.id}/lock_seats",
        params: { seat_ids: [seats[0].id, seats[1].id] },
        headers: auth_headers_for(user)

    expect(response).to have_http_status(:ok)

    lock_token = json.dig('data', 'lock_token')

    post '/api/v1/bookings',
        params: {
          booking: {
            show_id: show.id,
            seat_ids: [seats[0].id, seats[1].id],
            lock_token: lock_token
          }
        },
        headers: auth_headers_for(user).merge('Idempotency-Key' => 'idem-1')

    expect(response).to have_http_status(:created)

    booking_id = json.dig('data', 'id')
    booking = Booking.find(booking_id)

    Bookings::ConfirmService.call(booking)

    expect(booking.reload).to be_confirmed
  end
end
