class Stocks::CompanyEvent < ApplicationRecord
  belongs_to :company

  validates :direction_delta, numericality: {
    greater_than_or_equal_to: -10,
    less_than_or_equal_to: 10
  }
end
