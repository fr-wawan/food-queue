class MenuItem < ApplicationRecord
  acts_as_tenant :restaurant
  belongs_to :restaurant
  belongs_to :menu

  enum :status, { available: 0, unavailable: 1, sold_out: 2 }

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
end
