class Stocks::IndustrySnapshot < ApplicationRecord
  belongs_to :industry
  belongs_to :industry_event, optional: true

  validates :health, :delta, :direction, presence: true
  validates :recorded_on, presence: true, uniqueness: { scope: :industry_id }
end
