class Restaurant < ApplicationRecord
  has_many :users, dependent: :destroy

  enum :status, { active: 0, inactive: 1, suspended: 2 }

  validates :name, presence: true
  validates :subdomain, presence: true,
                      uniqueness: { case_sensitive: false },
                      format: { with: /\A[a-z0-9\-]+\z/ }
  validates :slug, presence: true,
                     uniqueness: { case_sensitive: false }
end
