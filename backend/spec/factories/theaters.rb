FactoryBot.define do
  factory :theater do
    name    { "PVR #{Faker::Address.community}" }
    city    { 'Mumbai' }
    address { Faker::Address.full_address }
    active  { true }
  end

  factory :screen do
    theater
    sequence(:name) { |i| "Screen #{i}" }
    rows    { 8 }
    columns { 10 }
    screen_type { 'standard' }
  end

  factory :seat do
    screen
    row_label    { 'A' }
    sequence(:column_index) { |i| i }
    category     { 'standard' }
    base_price   { 10.0 }
  end

  factory :show do
    movie
    screen
    starts_at        { 2.hours.from_now }
    ends_at          { 4.hours.from_now }
    price_multiplier { 1.0 }
    status           { :scheduled }
    language         { 'English' }
  end
end
