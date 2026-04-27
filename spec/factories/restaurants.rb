FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
    subdomain { Faker::Internet.unique.slug(glue: "-") }
    slug { subdomain }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    status { :active }
  end
end
