FactoryBot.define do
  factory :order_item do
    association :order
    association :menu_item

    quantity { 1 }
    unit_price { menu_item.price }
    subtotal { quantity * unit_price }
  end
end
