class Api::V1::MenusController < ApplicationController
  include Cacheable

  before_action :set_menu, only: [ :show, :update, :destroy ]

  def index
    authorize Menu

    @menus = Menu.cached_for(current_restaurant.id)


    render json: MenuBlueprint.render(@menus, view: :with_items)
  end

  def show
    authorize @menu
    render json: MenuBlueprint.render(@menu, view: :with_items)
  end

  def create
    @menu = Menu.new(menu_params)

    authorize @menu

    @menu.save!

    render json: MenuBlueprint.render(@menu), status: :created
  end

  def update
    authorize @menu

    @menu.update!(menu_params)

    render json: MenuBlueprint.render(@menu)
  end

  def destroy
    authorize @menu

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
