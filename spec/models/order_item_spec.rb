require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe "validations" do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
    it { should validate_numericality_of(:subtotal).is_greater_than(0) }
  end

  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:menu_item) }
  end

  describe "#calculate_subtotal" do
    it "automatically calculates subtotal as quantity * unit_price" do
      menu_item = create(:menu_item, price: 25_000)
      order_item = build(:order_item, menu_item: menu_item, quantity: 2, unit_price: menu_item.price)

      expect(order_item.subtotal).to eq(50_000)
    end

    it "recalculate when quantity changes" do
      menu_item = create(:menu_item, price: 25_000)
      order_item = create(:order_item, menu_item: menu_item, quantity: 1, unit_price: menu_item.price)

      order_item.update(quantity: 3)
      expect(order_item.subtotal).to eq(75_000)
    end

    it "recalculate when unit_price changes" do
      menu_item = create(:menu_item, price: 25_000)
      order_item = create(:order_item, menu_item: menu_item, quantity: 2, unit_price: menu_item.price)

      order_item.update(unit_price: 30_000)
      expect(order_item.subtotal).to eq(60_000)
    end
  end
end
