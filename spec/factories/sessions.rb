FactoryBot.define do
  factory :session do
    association :user
    jti { SecureRandom.uuid }
    token_digest { BCrypt::Password.create("sometoken") }
    expires_at { 24.hours.from_now }
    user_agent { Faker::Internet.user_agent }
    ip_address { Faker::Internet.ip_v4_address }
  end
end
