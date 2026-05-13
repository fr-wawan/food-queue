class Menu < ApplicationRecord
  acts_as_tenant :restaurant
  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }
  validates :name, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:position) }

  after_commit :invalidate_cache

  def self.cached_for(restaurant_id)
    Rails.cache.fetch("menus:#{restaurant_id}:v1", expires_in: 10.minutes) do
      includes(:menu_items).all.to_a
    end
  end

  private

  def invalidate_cache
    Rails.cache.delete("menus:#{restaurant_id}:v1")
  end
end
