class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :menu_item

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :subtotal, numericality: { greater_than: 0 }

  before_validation :calculate_subtotal

  private

  def calculate_subtotal
    self.subtotal = quantity * unit_price if quantity && unit_price
  end
end
