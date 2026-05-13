require 'rails_helper'

RSpec.describe NotifyOrderJob, type: :job do
  let(:restaurant) { create(:restaurant) }
  let(:user) { create(:user, restaurant: restaurant) }
  let(:order) { create(:order, restaurant: restaurant, user: user) }

  before { ActsAsTenant.current_tenant = restaurant }
  after { ActsAsTenant.current_tenant = nil }

  it "logs the order notification" do
    order_number = order.order_number
    allow(Rails.logger).to receive(:info)

    described_class.perform_now(order.id, restaurant.id)

    expect(Rails.logger).to have_received(:info).with(/#{order_number}/)
  end

  it "does nothing when order not found" do
    expect { described_class.perform_now(999, restaurant.id) }.not_to raise_error
  end
end
