class MenuItem < ApplicationRecord
  acts_as_tenant :restaurant
  belongs_to :restaurant
  belongs_to :menu

  searchkick word_middle: [ :name, :description ],
    callbacks: false

  enum :status, { available: 0, unavailable: 1, sold_out: 2 }

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  after_commit :invalidate_cache

  def self.cached_for(menu_id)
    Rails.cache.fetch("menu_items:#{menu_id}:v1", expires_in: 10.minutes) do
      where(menu_id: menu_id).all.to_a
    end
  end

  def search_data
    {
      name: name,
      description: description,
      status: status,
      restaurant_id: restaurant_id,
      menu_id: menu_id
    }
  end

  private

  def invalidate_cache
    Rails.cache.delete("menu_items:#{restaurant_id}:v1")
  end

  def enqueue_reindex
    ReindexMenuItemJob.perform_later(id)
  end
end
