class Menu < ApplicationRecord
  acts_as_tenant :restaurant
  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }
  validates :name, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:position) }
end
