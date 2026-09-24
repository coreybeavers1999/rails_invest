FactoryBot.define do
  factory :share_purchase, class: "Stocks::SharePurchase" do
    association :user
    association :company
  end
end
