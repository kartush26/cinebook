require 'rails_helper'

RSpec.describe Movie, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to validate_presence_of(:release_date) }
  it { is_expected.to define_enum_for(:status).with_values(draft: 0, now_showing: 1, upcoming: 2, archived: 3) }

  it 'requires at least one genre' do
    movie = build(:movie, genres: [])
    expect(movie).not_to be_valid
    expect(movie.errors[:genres]).to include('must include at least one genre')
  end

  it 'rejects an invalid rating' do
    expect(build(:movie, rating: 'X')).not_to be_valid
  end

  it 'scopes showing movies' do
    create(:movie, status: :draft)
    showing = create(:movie, status: :now_showing)
    expect(described_class.showing).to contain_exactly(showing)
  end
end
