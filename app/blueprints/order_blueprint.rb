class OrderBlueprint < Blueprinter::Base
  identifier :id
  fields :order_number, :status, :note, :total_price

  association :user, blueprint: UserBlueprint

  view :with_items do
    association :order_items, blueprint: OrderItemBlueprint
  end
end
