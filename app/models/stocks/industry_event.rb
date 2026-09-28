class Stocks::IndustryEvent < ApplicationRecord
  # Constants
  DIRECTION_RANGE = [ -5, 5 ].freeze

  belongs_to :industry
  has_one :industry_snapshot

  validates :new_direction, numericality: {
    greater_than_or_equal_to: -5,
    less_than_or_equal_to: 5,
    other_than: 0
  }
  validates :public, inclusion: { in: [ true, false ] }

  before_validation :initialize_values, on: :create

  private

  def initialize_values
    # To prevent flatlining, bounce off the boundaries
    min = industry.health.positive? ? DIRECTION_RANGE[0] : 1
    max = industry.health == 1000 ? -1 : DIRECTION_RANGE[1]

    # Randomly assign direction delta
    self.new_direction = SecureRandom.random_number(min..max)
    self.new_direction = [ -1, 1 ].sample if self.new_direction.zero? # Zero not allowed

    # Placeholder 50/50 chance of public
    self.public = rand(1..2) == 1
  end
end
