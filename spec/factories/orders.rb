FactoryBot.define do
  factory :order do
    association :restaurant
    association :user
    status { :pending }
    note { nil }
    total_price { 0 }
  end
end
