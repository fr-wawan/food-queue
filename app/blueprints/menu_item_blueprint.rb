class MenuItemBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :stock, :status, :menu_id
end
