FactoryBot.define do
  sequence(:industry_name) { |n| "Industry #{n}" }

  factory :industry, class: "Stocks::Industry" do
    name { generate(:industry_name) }
    seed { 123_456 }
  end
end
