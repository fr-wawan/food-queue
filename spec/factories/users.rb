FactoryBot.define do
  factory :user do
    association :restaurant
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    role { :staff }
  end
end
