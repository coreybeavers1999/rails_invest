FactoryBot.define do
  sequence(:ceo_name) { |n| "CEO #{n}" }

  factory :ceo, class: "Stocks::Ceo" do
    name { generate(:ceo_name) }
    retires_at { Date.current + 270.days }
    retired { false }
  end
end
