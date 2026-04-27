class User < ApplicationRecord
  belongs_to :restaurant

  acts_as_tenant :restaurant

  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { owner: 0, staff: 1, cashier: 2 }
  validates :name, presence: true
  validates :email, presence: true,
    uniqueness: { scope: :restaurant_id },
    format: { with: URI::MailTo::EMAIL_REGEXP }
end
