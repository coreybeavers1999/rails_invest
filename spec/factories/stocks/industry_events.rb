FactoryBot.define do
  factory :industry_event, class: "Stocks::IndustryEvent" do
    association :industry
    new_direction { 1 }
    public { false }
  end
end
