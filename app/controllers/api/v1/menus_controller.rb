class Api::V1::MenusController < ApplicationController
  include Cacheable

  before_action :set_menu, only: [ :show, :update, :destroy ]

  def index
    @menus = Menu.cached_for(current_restaurant.id)

    render json: MenuBlueprint.render(@menus, view: :with_items)
  end

  def show
    render json: MenuBlueprint.render(@menu, view: :with_items)
  end

  def create
    @menu = Menu.new(menu_params)

    @menu.save!

    render json: MenuBlueprint.render(@menu), status: :created
  end

  def update
    @menu.update!(menu_params)

    render json: MenuBlueprint.render(@menu)
  end

  def destroy
    @menu.destroy!

    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description, :position, :status)
  end
end
