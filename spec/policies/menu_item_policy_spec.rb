require 'rails_helper'

RSpec.describe MenuItemPolicy, type: :policy do
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant) }
  let(:menu_item)  { create(:menu_item, menu: menu, restaurant: restaurant) }

  context 'as owner' do
    subject { described_class.new(create(:user, restaurant: restaurant, role: :owner), menu_item) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:search) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'as staff' do
    subject { described_class.new(create(:user, restaurant: restaurant, role: :staff), menu_item) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:search) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'as cashier' do
    subject { described_class.new(create(:user, restaurant: restaurant, role: :cashier), menu_item) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:search) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
