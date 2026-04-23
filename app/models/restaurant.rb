class Restaurant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :menus, dependent: :destroy

  enum :status, { active: 0, inactive: 1, suspended: 2 }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
                        format: { with: /\A[a-z0-9\-]+\z/ }
  validates :slug, presence: true, uniqueness: true
end
