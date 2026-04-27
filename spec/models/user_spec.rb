require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should have_secure_password }

    describe "association" do
      it { should belong_to(:restaurant) }
      it { should have_many(:sessions).dependent(:destroy) }
    end

    describe "enums" do
      it { should define_enum_for(:role).with_values(owner: 0, staff: 1, cashier: 2) }
    end

    describe "email uniqueness per restaurant" do
      it "allows same email on different restaurants" do
        email = "same@test.com"

        create(:user, email: email)
        restaurant2 = create(:restaurant)

        user2 = build(:user, email: email, restaurant: restaurant2)

        expect(user2).to be_valid
      end

      it "rejects duplicate email on same restaurant" do
        user = create(:user)

        duplicate = build(:user, email: user.email, restaurant: user.restaurant)

        expect(duplicate).not_to be_valid
      end
    end
  end
end
