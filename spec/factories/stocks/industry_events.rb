FactoryBot.define do
  factory :industry_event, class: "Stocks::IndustryEvent" do
    association :industry
    direction_delta { 1 }
    public { false }
  end
end
