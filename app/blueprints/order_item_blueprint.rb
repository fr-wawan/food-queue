class OrderItemBlueprint < Blueprinter::Base
  identifier :id

  fields :quantity, :unit_price, :subtotal

  association :menu_item, blueprint: MenuItemBlueprint
end
