class Stocks::SharePurchase < ApplicationRecord
  belongs_to :user
  belongs_to :company
end
