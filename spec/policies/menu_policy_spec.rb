require 'rails_helper'

RSpec.describe MenuPolicy, type: :policy do
  let(:restaurant) { create(:restaurant) }
  let(:menu)       { create(:menu, restaurant: restaurant) }

  subject { described_class.new(user, menu) }

  context 'as owner' do
    let(:user) { create(:user, restaurant: restaurant, role: :owner) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'as staff' do
    let(:user) { create(:user, restaurant: restaurant, role: :staff) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'as cashier' do
    let(:user) { create(:user, restaurant: restaurant, role: :cashier) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
