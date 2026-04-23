FactoryBot.define do
  factory :user do
    restaurant { nil }
    name { "MyString" }
    email { "MyString" }
    password_digest { "MyString" }
    role { 1 }
  end
end
