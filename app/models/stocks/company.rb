# Represents a company in the stock market
#
# IMPORTANT:
# The direction property for companies does not work the same way
# direction in industries works. Because industries use a clamped health
# property instead of a cash value, the direction can be applied directly.
# For companies, the direction instead represents a percentage change in value
# that the strength of which is controlled by the COMPANY_DIRECTION_STRENGTH constant.
#
# DAILY UPDATE VALUE CALCULATION:
# value *= industry_effect + company_effect + company_noise
class Stocks::Company < ApplicationRecord
  # Constants
  DIRECTION_RANGE = [ 0, 100 ].freeze

  # Percentage each affector has on daily value change
  COMPANY_DIRECTION_STRENGTH    = 0.5
  INDUSTRY_DIRECTION_STRENGTH   = 0.2
  NOISE_STRENGTH                = 0.3

  belongs_to :industry
  has_one :ceo, dependent: :nullify
  has_many :ceo_employment_logs, dependent: :restrict_with_exception
  has_many :company_events, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :acronym, presence: true, uniqueness: true
  validates :industry, presence: true
  validates :seed, presence: true
  validates :direction, numericality: { greater_than_or_equal_to: DIRECTION_RANGE[0], less_than_or_equal_to: DIRECTION_RANGE[1] }

  before_validation :initialize_values, only: :create
  before_validation :clamp_values

  def daily_update; end

  def fire_ceo; end

  def create_event; end

  def age
    ((Date.current - created_at.to_date) + 1).to_i
  end

  private

  def initialize_values
    # Defaults values
    default_value_range = 1_000_000..1_000_000_000_000
    default_shares_issued_range = 100_000..1_000_000
    default_bankrupts_at_range = 0.05..0.25
    default_fires_ceo_at_range = -200..-50

    # Generate seed
    self.seed = SecureRandom.random_number(100_000..999_999)

    # Generate starting value and shares issued if not provided
    self.direction = SecureRandom.random_number(DIRECTION_RANGE[0]..DIRECTION_RANGE[1]) if self.direction.nil?
    self.value = SecureRandom.random_number(default_value_range) if self.value.nil?
    self.shares_issued = SecureRandom.random_number(default_shares_issued_range) if self.shares_issued.nil?
    self.fires_ceo_at = SecureRandom.random_number(default_fires_ceo_at_range) if self.fires_ceo_at.nil?

    if self.bankrupts_at.nil?
      selected_percentage = SecureRandom.random_number(default_bankrupts_at_range)
      self.bankrupts_at = self.value * selected_percentage
    end
  end

  def clamp_values
    self.direction = MathService.clamp(self.direction, DIRECTION_RANGE[0], DIRECTION_RANGE[1])
  end
end
