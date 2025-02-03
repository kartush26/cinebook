require 'rails_helper'

RSpec.describe Bookings::SeatLockService, :real_redis do
  let(:user)   { create(:user) }
  let(:screen) { create(:screen, rows: 2, columns: 2) }

  let!(:seats) do
    [
      create(:seat, screen: screen, row_label: 'A', column_index: 1),
      create(:seat, screen: screen, row_label: 'A', column_index: 2)
    ]
  end

  let(:show) { create(:show, screen: screen) }

  it 'locks all-or-nothing — succeeds when no overlap' do
    result = described_class.lock!(
      show_id: show.id,
      seat_ids: seats.map(&:id),
      user_id: user.id
    )

    expect(result.lock_token).to be_present

    expect(
      described_class.locked_seat_ids_for(show.id)
    ).to match_array(seats.map(&:id).map(&:to_s))
  end

  it 'rejects when any seat is already locked by another user' do
    described_class.lock!(
      show_id: show.id,
      seat_ids: [seats.first.id],
      user_id: user.id
    )

    other = create(:user)

    expect do
      described_class.lock!(
        show_id: show.id,
        seat_ids: seats.map(&:id),
        user_id: other.id
      )
    end.to raise_error(Bookings::Errors::SeatUnavailable)
  end

  it 'rejects when any seat is already booked at the DB level' do
    booking = Booking.create!(
      user: user,
      show: show,
      status: :pending,
      seats_count: 1,
      total_amount: 10
    )

    BookingSeat.create!(
      booking: booking,
      seat: seats.first,
      show: show,
      price: 10,
      active: true
    )

    expect do
      described_class.lock!(
        show_id: show.id,
        seat_ids: seats.map(&:id),
        user_id: user.id
      )
    end.to raise_error(Bookings::Errors::SeatUnavailable)
  end

  it 'verifies the token correctly' do
    result = described_class.lock!(
      show_id: show.id,
      seat_ids: [seats.first.id],
      user_id: user.id
    )

    expect do
      described_class.verify!(
        show_id: show.id,
        seat_ids: [seats.first.id],
        user_id: user.id,
        lock_token: result.lock_token
      )
    end.not_to raise_error

    expect do
      described_class.verify!(
        show_id: show.id,
        seat_ids: [seats.first.id],
        user_id: user.id,
        lock_token: 'wrong'
      )
    end.to raise_error(Bookings::Errors::InvalidLockToken)
  end

  it 'releases locks and removes from index' do
    result = described_class.lock!(
      show_id: show.id,
      seat_ids: seats.map(&:id),
      user_id: user.id
    )

    described_class.release!(
      show_id: show.id,
      seat_ids: seats.map(&:id),
      user_id: user.id,
      lock_token: result.lock_token
    )

    expect(
      described_class.locked_seat_ids_for(show.id)
    ).to be_empty
  end
end