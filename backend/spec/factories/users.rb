FactoryBot.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'Secret@12345' }
    role  { :customer }
    active { true }

    factory :admin do
      role { :admin }
    end
  end
end
