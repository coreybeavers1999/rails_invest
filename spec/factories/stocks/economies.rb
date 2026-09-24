FactoryBot.define do
  factory :economy, class: "Stocks::Economy" do
    id { 1 }
    health { 500 }
  end
end
