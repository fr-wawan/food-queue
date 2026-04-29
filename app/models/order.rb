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

  validates :order_number, presence: true, uniqueness: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_order_number, on: :create

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end
