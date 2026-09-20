# Represents an industry in the stock market
#
# IMPORTANT:
# The health property of an industry directly affects the DAILY UPDATE value
# of each company of the industry. The health is normalized as a 0-1000 value
# and the effect the health of an industry has on the companies' value is
# configurable.
#
# DAILY UPDATE HEALTH CALCULATION:
# The direction is directly applied to the current health, but to prevent from
# having boring, clean increases and decreases, noise is added at a configurable
# strength to the final health.
# health += direction + (noise * noise_strength)
#
# DAILY UPDATE:
# - Roll dice for random industry events. Apply direction immediately if created
# - The clamped direction is directly added to the current industry health
class Stocks::Industry < ApplicationRecord
  # Constants
  DIRECTION_RANGE = [ -10, 10 ].freeze
  NOISE_STRENGTH = 0.5 # Percentage of the direction range. 0.5 = +10, 1.0 = +20, 0.0 = no noise.

  has_many :companies, dependent: :restrict_with_exception
  has_many :industry_events, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :health, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
  validates :direction, numericality: { greater_than_or_equal_to: DIRECTION_RANGE[0], less_than_or_equal_to: DIRECTION_RANGE[1] }
  validates :event_chance, numericality: { greater_than: 0 }
  validates :seed, presence: true

  before_validation :initialize_values, only: :create
  before_validation :clamp_values

  def daily_update; end

  def create_event; end

  def age
    ((Date.current - created_at.to_date) + 1).to_i
  end

  private

  def initialize_values
    # Randomly assign starting direction
    self.direction = SecureRandom.random_number(DIRECTION_RANGE[0]..DIRECTION_RANGE[1])

    # Generate seed and set starting health
    self.seed = SecureRandom.random_number(100_000..999_999)
    self.health = NoiseService.step_value(self.seed, 1)
  end

  def clamp_values
    self.health = MathService.clamp(self.health, 0, 1000)
    self.direction = MathService.clamp(self.direction, DIRECTION_RANGE[0], DIRECTION_RANGE[1])
  end

end
