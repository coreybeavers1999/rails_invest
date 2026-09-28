class Stocks::Economy < ApplicationRecord
  SEED = 1838

  validates :health, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }

  before_validation :clamp_health

  # Display the historical value of economy between two dates
  # @param [date_from] Date
  # @param [date_to] Date
  # Returns Array<[String, Integer]>
  def self.history(from: Date.current, to: Date.current)
    # Query the noise values between the dates and normalize them for economy values
    values = NoiseService.date_range_value(SEED, from, to).map { |i| self.normalize_noise(i) }
    date_strings = (from..to).map(&:iso8601)

    # Zip up iso strings with health value
    date_strings.zip(values)
  end

  def daily_update(today)
    # Sample perlin noise at this date and normalize it to the health range
    raw_noise = NoiseService.date_value(SEED, today)
    health = self.normalize_noise(raw_noise)

    update!(health: health)
  end

  def health_on_date(date)
    val = Stocks::Economy.history(from: date, to: date)
    val[0][1]
  end

  private

  # Clamp noise to a range of 0 to 1000
  def self.normalize_noise(noise)
    MathService.clamp(noise * 1000, 0, 1000).round
  end

  def clamp_health
    self.health = MathService.clamp(self.health, 0, 1000)
  end
end
