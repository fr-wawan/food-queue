class NotifyOrderJob < ApplicationJob
  queue_as :critical

  def perform(order_id, restaurant_id)
    restaurant = Restaurant.find_by(id: restaurant_id)

    return unless restaurant

    ActsAsTenant.with_tenant(restaurant) do
      order = Order.find_by(id: order_id)

      return unless order

      Rails.logger.info("[NotifyOrderJob] New order: #{order.order_number} - #{order.total_price}")
    end
  end
end
