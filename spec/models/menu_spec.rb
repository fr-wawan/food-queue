require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:position).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:restaurant) }
    it { should have_many(:menu_items).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "default scope" do
    it "orders by position" do
      restaurant = create(:restaurant)
      ActsAsTenant.with_tenant(restaurant) do
        menu0 = create(:menu, restaurant: restaurant, position: 0)
        menu1 = create(:menu, restaurant: restaurant, position: 1)
        menu2 = create(:menu, restaurant: restaurant, position: 2)
        expect(Menu.all).to eq([ menu0, menu1, menu2 ])
      end
    end
  end
end
