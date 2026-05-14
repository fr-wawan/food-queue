require 'rails_helper'

RSpec.describe OrderPolicy, type: :policy do
  let(:restaurant) { create(:restaurant) }
  let(:owner)      { create(:user, restaurant: restaurant, role: :owner) }
  let(:order)      { create(:order, restaurant: restaurant, user: owner) }

  context 'as owner' do
    subject { described_class.new(owner, order) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
  end

  context 'as staff' do
    let(:staff) { create(:user, restaurant: restaurant, role: :staff) }
    subject { described_class.new(staff, order) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
  end

  context 'as cashier' do
    let(:cashier) { create(:user, restaurant: restaurant, role: :cashier) }
    subject { described_class.new(cashier, order) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to forbid_action(:update) }
  end
end
