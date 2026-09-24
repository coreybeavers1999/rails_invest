FactoryBot.define do
  sequence(:company_name) { |n| "Company #{n}" }
  sequence(:company_acronym) { |n| "CMP#{n}" }

  factory :company, class: "Stocks::Company" do
    name { generate(:company_name) }
    acronym { generate(:company_acronym) }
    association :industry
    value { 1_000_000 }
    shares_issued { 100_000 }
    fires_ceo_at { -100 }
    bankrupts_at { 100_000 }
    seed { 123_456 }
  end
end
