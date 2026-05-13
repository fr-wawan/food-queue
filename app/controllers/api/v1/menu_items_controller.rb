class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu, only: [ :index, :create ]
  before_action :set_menu_item, only: [ :show, :update, :destroy ]

  def index
    @menu_items = @menu.menu_items.all

    render json: MenuItemBlueprint.render(@menu_items)
  end

  def search
    query = params[:q].presence || "*"
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    filters = { status: "available" }
    filters[:menu_id] = params[:menu_id] if params[:menu_id].present?

    @menu_items = MenuItem.search(
      query,
      where: filters,
      order: { name: :asc },
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    )

    render json: {
      data: MenuItemBlueprint.render_as_hash(@menu_items.to_a),
      meta: {
        total: @menu_items.total_count,
        page: page,
        per_page: per_page
      }
    }
  end

  def show
    render json: MenuItemBlueprint.render(@menu_item)
  end

  def create
    @menu_item = @menu.menu_items.new(menu_item_params)

    @menu_item.save!

    render json: MenuItemBlueprint.render(@menu_item), status: :created
  end

  def update
    @menu_item.update!(menu_item_params)

    render json: MenuItemBlueprint.render(@menu_item)
  end

  def destroy
    @menu_item.destroy!

    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:menu_id])
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :stock, :status)
  end
end
