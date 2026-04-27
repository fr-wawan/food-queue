FactoryBot.define do
  factory :menu_item do
    association :restaurant
    association :menu

    name { Faker::Food.dish }
    description { Faker::Food.description }
    price { Faker::Commerce.price(range: 10_000..100_000) }
    stock { 10 }
    status { :available }
  end
end
