FactoryBot.define do
  factory :session do
    user { nil }
    jti { "MyString" }
    expires_at { "2026-04-23 13:52:19" }
    user_agent { "MyString" }
    ip_address { "MyString" }
  end
end
