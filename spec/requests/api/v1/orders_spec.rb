require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:user) { create(:user, restaurant: restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }
  let(:menu_item) { create(:menu_item, menu: menu, restaurant: restaurant, price: 25_000, stock: 10) }
  let(:headers) { auth_headers(user) }

  before { ActsAsTenant.current_tenant = restaurant }
  after { ActsAsTenant.current_tenant =  nil }

  let(:valid_params) do
    {
      order: {
        note: "Tanpa bawang",
        items: [
          { menu_item_id: menu_item.id, quantity: 2 }
        ]
      }
    }
  end

  describe "GET /api/v1/orders" do
    it "returns all orders" do
      create_list(:order, 3, restaurant: restaurant, user: user)

      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(3)
    end
  end

  describe "GET /api/v1/orders/:id" do
    let(:order) { create(:order, restaurant: restaurant, user: user) }

    it "returns order with items" do
      get "/api/v1/orders/#{order.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["order_number"]).to eq(order.order_number)
    end

    it "returns 404 when not found" do
      get "/api/v1/orders/999", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    it "create new order with items" do
      expect {
        post "/api/v1/orders", params: valid_params, headers: headers, as: :json
      }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["order_number"]).to match(/\AORD-\d{8}-[A-F0-9]{8}\z/)
      expect(json["total_price"]).to eq("50000.0")
      expect(json["order_items"].length).to eq(1)
    end

    it "rollbacks when menu_item doesn't exist" do
      params = { order: { items: [ { menu_item_id: 999, quantity: 1 } ] } }

      expect {
        post "/api/v1/orders", params: params, headers: headers, as: :json
      }.not_to change(Order, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "rollbacks when stock is not enough" do
      params = { order: { items: [ { menu_item_id: menu_item.id, quantity: 999 } ] } }

      expect {
        post "/api/v1/orders", params: params, headers: headers, as: :json
      }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PUT /api/v1/orders/:id" do
    let(:order) { create(:order, restaurant: restaurant, user: user, status: :pending) }

    it "update status with valid transition" do
      put "/api/v1/orders/#{order.id}",
        params: { status: "confirmed" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:ok)
      expect(json["status"]).to eq("confirmed")
    end

    it "returns 422 when invalid transition" do
      put "/api/v1/orders/#{order.id}",
        params: { status: "delivered" },
        headers: headers,
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
