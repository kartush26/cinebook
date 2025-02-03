require 'rails_helper'

RSpec.describe Bookings::CreateService, :real_redis do
  let(:user)   { create(:user) }
  let(:screen) { create(:screen, rows: 1, columns: 4) }

  let!(:seats) do
    (1..4).map do |i|
      create(:seat, screen: screen, row_label: 'A', column_index: i)
    end
  end

  let(:show) { create(:show, screen: screen, price_multiplier: 1.0) }

  before do
    REDIS.with(&:flushdb)

    # mock Stripe so no network call
    allow(Stripe::PaymentIntent).to receive(:create).and_return(
      Struct.new(:id, :client_secret).new(
        'pi_test_123',
        'cs_test_xyz'
      ).tap do |s|
        def s.to_hash
          {
            id: id,
            client_secret: client_secret
          }
        end
      end
    )
  end

  after do
    REDIS.with(&:flushdb)
  end

  it 'creates a pending booking + booking_seats + payment in one transaction' do
    lock = Bookings::SeatLockService.lock!(
      show_id: show.id,
      seat_ids: seats.first(2).map(&:id),
      user_id: user.id
    )

    res = described_class.new(
      user: user,
      show_id: show.id,
      seat_ids: seats.first(2).map(&:id),
      lock_token: lock.lock_token
    ).call

    expect(res.booking).to be_pending
    expect(res.booking.booking_seats.count).to eq(2)
    expect(res.payment.provider).to eq('stripe')
    expect(res.payment.external_id).to eq('pi_test_123')
  end

  it 'is idempotent for same Idempotency-Key' do
    lock = Bookings::SeatLockService.lock!(
      show_id: show.id,
      seat_ids: [seats[0].id],
      user_id: user.id
    )

    args = {
      user: user,
      show_id: show.id,
      seat_ids: [seats[0].id],
      lock_token: lock.lock_token,
      idempotency_key: 'fixed'
    }

    first = described_class.new(**args).call
    second = described_class.new(**args).call

    expect(second.booking.id).to eq(first.booking.id)
  end

  it 'rejects an expired or wrong lock token' do
    expect do
      described_class.new(
        user: user,
        show_id: show.id,
        seat_ids: [seats[0].id],
        lock_token: 'bogus'
      ).call
    end.to raise_error(Bookings::Errors::LockExpired)
  end

  it 'rejects double booking even when Redis lock is bypassed (DB unique index wins)' do
    other = create(:user)

    Bookings::SeatLockService.lock!(
      show_id: show.id,
      seat_ids: [seats[0].id],
      user_id: user.id
    )

    lock = Bookings::SeatLockService.lock!(
      show_id: show.id,
      seat_ids: [seats[1].id],
      user_id: user.id
    )

    described_class.new(
      user: user,
      show_id: show.id,
      seat_ids: [seats[1].id],
      lock_token: lock.lock_token
    ).call

    other_booking = Booking.create!(
      user: other,
      show: show,
      status: :pending,
      seats_count: 1,
      total_amount: 10
    )

    expect do
      BookingSeat.create!(
        booking: other_booking,
        seat: seats[1],
        show: show,
        price: 10,
        active: true
      )
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end