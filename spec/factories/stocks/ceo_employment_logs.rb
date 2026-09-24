FactoryBot.define do
  factory :ceo_employment_log, class: "Stocks::CeoEmploymentLog" do
    association :ceo
    association :company
    started_on { Date.current }
  end
end
