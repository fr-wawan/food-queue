require 'rails_helper'

RSpec.describe ReindexMenuItemJob, type: :job do
  let(:restaurant) { create(:restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }
  let(:menu_item) { create(:menu_item, restaurant: restaurant, menu: menu) }

  before { ActsAsTenant.current_tenant = restaurant }
  after { ActsAsTenant.current_tenant = nil }

  it "reindexes the menu item" do
    allow(MenuItem).to receive(:find_by).with(id: menu_item.id).and_return(menu_item)
    expect(menu_item).to receive(:reindex)

    described_class.perform_now(menu_item.id)
  end

  it "does nothing when menu item not found" do
  expect { described_class.perform_now(999) }.not_to raise_error
  end
end
