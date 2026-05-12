class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :update ]

  def index
    @orders = Order.includes(:order_items, :menu_items).all

    render json: OrderBlueprint.render(@orders, view: :with_items)
  end

  def show
    render json: OrderBlueprint.render(@order, view: :with_items)
  end

  def create
    @order = Order.new(order_params.except(:items))

    @order.user = current_user

    Order.transaction do
      @order.save!
      build_order_items!
      @order.update!(total_price: calculate_total)
    end

    render json: OrderBlueprint.render(@order, view: :with_items), status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def update
    @order.update!(status: params[:status])

    render json: OrderBlueprint.render(@order)
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:note, items: [ :menu_item_id, :quantity ])
  end

  def build_order_items!
    order_params[:items].each do |item|
      menu_item = MenuItem.find(item[:menu_item_id])
      quantity = item[:quantity].to_i

      if menu_item.stock < quantity
        menu_item.errors.add(:stock, "tidak cukup: diminta #{quantity}, tersedia #{menu_item.stock}")
        raise ActiveRecord::RecordInvalid.new(menu_item)
      end

      @order.order_items.create!(
        menu_item: menu_item,
        quantity: item[:quantity],
        unit_price: menu_item.price
      )
    end
  end

  def calculate_total
    @order.order_items.sum(:subtotal)
  end
end
