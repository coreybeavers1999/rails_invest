FactoryBot.define do
  factory :stocks_industry_snapshot, class: 'Stocks::IndustrySnapshot' do
    industry { nil }
    recorded_on { "2026-09-26" }
    health { 1 }
    delta { 1 }
  end
end
