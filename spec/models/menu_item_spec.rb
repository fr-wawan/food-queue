require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { should belong_to(:restaurant) }
    it { should belong_to(:menu) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(available: 0, unavailable: 1, sold_out: 2) }
  end
end
