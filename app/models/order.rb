class Order < ApplicationRecord
  acts_as_tenant :restaurant
  belongs_to :restaurant
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :menu_items, through: :order_items

  enum :status, {
    pending: 0,
    confirmed: 1,
    preparing: 2,
    ready: 3,
    delivered: 4,
    cancelled: 5
  }

  TRANSITIONS = {
    "pending"   => %w[confirmed cancelled],
    "confirmed" => %w[preparing cancelled],
    "preparing" => %w[ready],
    "ready"     => %w[delivered]
  }.freeze


  validates :order_number, presence: true, uniqueness: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_status_transition, if: :status_changed?

  before_validation :generate_order_number, on: :create

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def validate_status_transition
    allowed = TRANSITIONS[status_was] || []
    unless allowed.include?(status)
      errors.add(:status, "cannot transition from #{status_was} to #{status}")
    end
  end
end
