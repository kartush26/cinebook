require 'rails_helper'

RSpec.describe Show, type: :model do
  it 'rejects overlapping shows on same screen' do
    screen = create(:screen)
    create(:show, screen: screen, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
    overlap = build(:show, screen: screen, starts_at: 2.hours.from_now, ends_at: 4.hours.from_now)

    expect(overlap).not_to be_valid
    expect(overlap.errors[:base]).to include(/overlaps/)
  end

  it 'allows back-to-back shows on same screen' do
    screen = create(:screen)
    create(:show, screen: screen, starts_at: 1.hour.from_now, ends_at: 3.hours.from_now)
    next_show = build(:show, screen: screen, starts_at: 3.hours.from_now, ends_at: 5.hours.from_now)
    expect(next_show).to be_valid
  end
end
