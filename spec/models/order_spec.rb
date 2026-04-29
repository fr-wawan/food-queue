require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "validations" do
    it "requires order_number" do
      order = build(:order)
      order.order_number = nil

      allow(order).to receive(:generate_order_number)
      order.valid?
      expect(order.errors[:order_number]).to include("can't be blank")
    end
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:restaurant) }
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:menu_items).through(:order_items) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(
      pending: 0, confirmed: 1, preparing: 2,
      ready: 3, delivered: 4, cancelled: 5
    ) }
  end

  describe "#generate_order_number" do
    it "auto-generates order_number before creation" do
      order = create(:order)
      expect(order.order_number).to match(/\AORD-\d{8}-[A-F0-9]{8}\z/)
    end

    it "doesn't override existing order_number" do
      order = create(:order, order_number: "ORD-20240101-12345678")
      expect(order.order_number).to eq("ORD-20240101-12345678")
    end
  end
end
