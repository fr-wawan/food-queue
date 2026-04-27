require 'rails_helper'

RSpec.describe Session, type: :model do
  subject { build(:session) }
  describe "validations" do
    it { should validate_presence_of(:jti) }
    it { should validate_uniqueness_of(:jti).case_insensitive }
    it { should validate_presence_of(:expires_at) }
    it { should belong_to(:user) }
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      session = build(:session, expires_at: 1.hour.ago)

      expect(session.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      session = build(:session, expires_at: 1.hour.from_now)

      expect(session.expired?).to be false
    end
  end
end
