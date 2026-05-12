class MenuBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :description, :position, :status

  view :with_items do
    association :menu_items, blueprint: MenuItemBlueprint
  end
end
