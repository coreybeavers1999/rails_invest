FactoryBot.define do
  factory :company_event, class: "Stocks::CompanyEvent" do
    association :company
    direction_delta { 1 }
    public { false }
  end
end
