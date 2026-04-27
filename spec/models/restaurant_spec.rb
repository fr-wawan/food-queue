require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  subject { build(:restaurant) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subdomain) }
    it { should validate_uniqueness_of(:subdomain).case_insensitive }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug).case_insensitive }

    it "rejects invalid subdomain format" do
      restaurant = build(:restaurant, subdomain: "Warung Bu Sari!")

      expect(restaurant).not_to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:users).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(active: 0, inactive: 1, suspended: 2) }
  end
end
