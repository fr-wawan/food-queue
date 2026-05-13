class ReindexMenuItemJob < ApplicationJob
  queue_as :low

  def perform(menu_item_id)
    menu_item = MenuItem.find_by(id: menu_item_id)

    return unless menu_item

    menu_item.reindex
  end
end
