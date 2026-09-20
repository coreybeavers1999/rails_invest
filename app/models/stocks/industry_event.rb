class Stocks::IndustryEvent < ApplicationRecord
  belongs_to :industry

  validates :direction_delta, numericality: {
    greater_than_or_equal_to: -5,
    less_than_or_equal_to: 5,
    other_than: 0
  }
  validates :public, inclusion: { in: [ true, false ] }
end
