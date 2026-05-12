require 'rails_helper'

RSpec.describe "Api::V1::Menus", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:user) { create(:user, restaurant: restaurant) }
  let(:headers) { auth_headers(user) }

  before { ActsAsTenant.current_tenant = restaurant }
  after { ActsAsTenant.current_tenant = nil }

  describe "GET /api/v1/menus" do
    it "returns all menus" do
      create_list(:menu, 3, restaurant: restaurant)
      get "/api/v1/menus", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(3)
    end

    it "returns 401 without token" do
      get "/api/v1/menus"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/menus/:id" do
    let(:menu) { create(:menu, restaurant: restaurant) }

    it "returns menu with items" do
      create_list(:menu_item, 2, menu: menu, restaurant: restaurant)
      get "/api/v1/menus/#{menu.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(menu.id)
      expect(json["menu_items"].length).to eq(2)
    end

    it "returns 404 if not found" do
      get "/api/v1/menus/999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/menus" do
    let(:valid_params) { { menu: { name: "Makanan", description: "Deskripsi", position: 0, status: "active" } } }

    it "create new menu" do
      expect {
        post "/api/v1/menus", params: valid_params, headers: headers, as: :json
      }.to change(Menu, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Makanan")
    end

    it "returns 422 if invalid" do
      post "/api/v1/menus", params: { menu: { name: "" } }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end
  end

  describe "PUT /api/v1/menus/:id" do
    let(:menu) { create(:menu, restaurant: restaurant) }

    it "update menus" do
      put "/api/v1/menus/#{menu.id}",
        params: { menu: { name: "Updated" } },
        headers: headers,
        as: :json
      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Updated")
    end
  end

  describe "DELETE /api/v1/menus/:id" do
    let!(:menu) { create(:menu, restaurant: restaurant) }

    it "delete menu" do
      expect {
        delete "/api/v1/menus/#{menu.id}", headers: headers
      }.to change(Menu, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
