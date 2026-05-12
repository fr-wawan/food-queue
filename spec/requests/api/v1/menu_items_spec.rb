require 'rails_helper'

RSpec.describe "Api::V1::MenuItems", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:user) { create(:user, restaurant: restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }
  let(:headers) { auth_headers(user) }

  before { ActsAsTenant.current_tenant = restaurant }
  after { ActsAsTenant.current_tenant = nil }

  describe "GET /api/v1/menus/:menu_id/menu_items" do
    it "returns all menu items" do
      create_list(:menu_item, 3, menu: menu, restaurant: restaurant)

      get "/api/v1/menus/#{menu.id}/menu_items", headers: headers

      expect(response).to have_http_status(:ok)

      expect(json.length).to eq(3)
    end
  end

  describe "GET /api/v1/menu_items/:id" do
    let(:menu_item) { create(:menu_item, menu: menu, restaurant: restaurant) }

    it "returns menu item" do
      get "/api/v1/menu_items/#{menu_item.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(menu_item.id)
    end
  end

  describe "POST /api/v1/menus/:menu_id/menu_items" do
    let(:valid_params) do
      {
        menu_item: {
          name: "Nasi Goreng",
          description: "Enak",
          price: 25_000,
          stock: 10,
          status: "available"
        }
      }
    end

    it "create new menu item" do
      expect {
        post "/api/v1/menus/#{menu.id}/menu_items",
        params: valid_params,
        headers: headers,
        as: :json
      }.to change(MenuItem, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Nasi Goreng")
      expect(json["price"]).to eq("25000.0")
    end

    it "returns 422 when price is empty" do
      post "/api/v1/menus/#{menu.id}/menu_items",
        params: { menu_item: { name: "Test", price: nil } },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PUT /api/v1/menu_items/:id" do
    let(:menu_item) { create(:menu_item, menu: menu, restaurant: restaurant) }

    it "update menu item" do
      put "/api/v1/menu_items/#{menu_item.id}",
        params: { menu_item: { stock: 99 } },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      expect(json["stock"]).to eq(99)
    end
  end

  describe "DELETE /api/v1/menu_items/:id" do
    let!(:menu_item) { create(:menu_item, menu: menu, restaurant: restaurant) }

    it "delete menu item" do
      expect {
        delete "/api/v1/menu_items/#{menu_item.id}", headers: headers
      }.to change(MenuItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
