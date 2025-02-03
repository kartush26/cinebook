FactoryBot.define do
  factory :movie do
    title           { Faker::Movie.title }
    synopsis        { Faker::Lorem.paragraph }
    duration_minutes { rand(95..170) }
    language        { 'English' }
    rating          { %w[U UA A].sample }
    genres          { %w[Action Drama] }
    cast            { Array.new(3) { Faker::Name.name } }
    director        { Faker::Name.name }
    release_date    { 1.month.ago.to_date }
    status          { :now_showing }
    imdb_rating     { 7.8 }
  end
end
