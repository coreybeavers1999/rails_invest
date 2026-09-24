FactoryBot.define do
  sequence(:user_email) { |n| "user#{n}@example.com" }

  factory :user do
    email { generate(:user_email) }
    password { "password123" }
  end
end
