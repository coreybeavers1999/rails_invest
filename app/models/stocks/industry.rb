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
# health += direction + (noise * noise_strength) + (economy_health * economy_strength)
#
# DAILY UPDATE:
# - Roll dice for random industry events. Apply direction immediately if created
# - The clamped direction is directly added to the current industry health
#
# WHEN CREATING:
# On creation a seed is generated unless one is provided. It will then use the created_at
# date (or Date.current if no created_at date provided) with the seed in NoiseService.date_value.
# If you need predetermined values for health, pass a set seed and created_at date. That will
# allow you to create historical companies that started at a prior date without noticeable value
# jumps when it runs the next update.
class Stocks::Industry < ApplicationRecord
  # Constants
  DIRECTION_RANGE = [ -10, 10 ].freeze
  NOISE_STRENGTH_PERCENT = 0.25 # Percentage of the total direction range. 0.5 = +10, 1.0 = +20, 0.0 = no noise.
  ECONOMY_STRENGTH_PERCENT = 0.02 # Percentage of economy health range normalized to (-500..500)

  has_many :companies, dependent: :restrict_with_exception
  has_many :industry_events, dependent: :restrict_with_exception
  has_many :industry_snapshots, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :health, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
  validates :direction, numericality: { greater_than_or_equal_to: DIRECTION_RANGE[0], less_than_or_equal_to: DIRECTION_RANGE[1] }
  validates :event_chance, numericality: { greater_than_or_equal_to: 0 }
  validates :seed, presence: true

  before_validation :initialize_values, on: :create
  before_validation :clamp_values

  after_create :backfill_history

  # Updates the industry health and calculates events
  # @param [economy] <Economy> The single economy instance
  # @param [date] <Date> The date to update the industry for
  def daily_update(economy, date)
    # Noise strength is the configured percent (how much does noise affect the industry's health) * total direction range
    noise = noise_by_date(date) # Between 0.0..1.0
    noise_delta = noise_to_delta(noise)

    # Economy strength is between -500..500. Multiply it by the economy strength percent and rounded to int
    # Economy daily health is calculated each day before daily update runs here. In the off chance we are
    # backfilling historical data, fetch the economy health for a given date
    economy_health = date == Date.current ? economy.health : economy.health_on_date(date)
    economy_amount = (economy_health_to_modifier(economy_health) * ECONOMY_STRENGTH_PERCENT).round

    # Create an event if the dice speak it so. If there was an event, apply the updated direction
    event = todays_event(date:)
    self.direction = event.new_direction if event.present?

    # Calculate today's delta
    delta = self.direction + noise_delta + economy_amount

    # Add the current direction + noise
    self.health += delta
    self.save

    # Create a new snapshot for today
    # I'm doing this here and not in a callback to have access to delta and event created
    Stocks::IndustrySnapshot.create!(
      industry: self,
      recorded_on: date,
      health: self.health,
      direction: self.direction,
      industry_event: event,
      delta: delta
    )
  end

  def history(from: Date.current, to: Date.current)
    Stocks::IndustrySnapshot
      .select(:recorded_on, :health)
      .where(industry: self, recorded_on: from..to)
      .order(:recorded_on)
      .map do |snapshot|
      [ snapshot.recorded_on.iso8601, snapshot.health ]
    end
  end

  # Gathers all public events and formats them to display on a chart
  def chart_event_points(from: Date.current, to: Date.current)
    industry_snapshots
      .joins(:industry_event)
      .includes(:industry_event)
      .where(recorded_on: from..to)
      .order(:recorded_on)
      .map do |snapshot|
      {
        coord: [ snapshot.recorded_on, snapshot.health ],
        value: snapshot.industry_event.new_direction
      }
    end
  end

  private

  # Called before creation to randomly assign starting values unless explicitly provided
  def initialize_values
    # Randomly assign starting direction
    self.direction = SecureRandom.random_number(DIRECTION_RANGE[0]..DIRECTION_RANGE[1])

    # Generate seed and set starting health
    self.seed = SecureRandom.random_number(100_000..999_999) unless self.seed

    # Query random noise at step 1 and the convert to health value
    # If a created_at date was provided, use it as the starting noise value
    date = self.created_at&.to_date || Date.current
    noise = NoiseService.date_value(self.seed, date)
    self.health = (noise * 1000).round
  end

  # Called after_create to backfill historical health/event files.
  # Iterates over every day between created_at and Date.current, calling daily_update for each
  def backfill_history
    # Find the singleton economy instance
    economy = Stocks::Economy.first

    # For each date in the range of created_at and Date.current, call daily update
    # If created_at is the same as Date.current, it will only call daily update 1 time for today
    (self.created_at.to_date..Date.current).each { |d| daily_update(economy, d) }
  end

  # Runs a check to see if we need an event today or not.
  # @param [Date] date used in place of Date.current for backfilling
  # @return [IndustryEvent || nil] Returns an industry event model if created. Otherwise, nil
  def todays_event(date: Date.current)
    # This alternate system increases the chance by 1% every day without an event.
    # I am disabling this for now because calculating expected events is more complex than it's really worth
    # How many has it been since the last event? If there has never been an event, use days since created at
    # last_event_date = latest_event&.created_at
    # days_since_last_event = (date - (last_event_date&.to_date || created_at.to_date)).to_i
    # chance = days_since_last_event + event_chance
    # dice_roll = rand(1..100)

    # Return nil or event created
    return nil if rand(1..100) > event_chance
    industry_events.create!(created_at: date)
  end

  def create_event; end

  def clamp_values
    self.health = MathService.clamp(self.health.round, 0, 1000)
    self.direction = MathService.clamp(self.direction.round, DIRECTION_RANGE[0], DIRECTION_RANGE[1])
  end

  # Converts raw economy health (0..1000) to modifier value (-500..500)
  def economy_health_to_modifier(health)
    health - 500
  end

  # Fetches industry-specific noise by a given date
  def noise_by_date(date)
    # Sample noise at this date
    NoiseService.date_value(self.seed, date, noise_params: NoiseService::NOISE_PARAMS[:industry])
  end

  # Converts a normalized noise value to a delta applied to daily health change
  # Math: noise * strength * (range - range / 2)
  # @return [Integer] value between min and max direction delta * noise strength
  def noise_to_delta(noise)
    total_range = DIRECTION_RANGE[1] - DIRECTION_RANGE[0]
    (((noise * total_range) - (total_range / 2)) * NOISE_STRENGTH_PERCENT).round
  end
end
