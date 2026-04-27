FactoryBot.define do
  factory :menu do
    association :restaurant
    name { Faker::Food.ethnic_category }
    description { Faker::Lorem.sentence }
    position { 0 }
    status { :active }
  end
end
