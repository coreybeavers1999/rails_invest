class Stocks::Economy < ApplicationRecord
  SEED = 1838284

  validates :health, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }

  def daily_update
    current_step = self.date_to_step(Date.current)
    raw_noise = NoiseService.step_value(SEED, current_step)
    health = self.normalize_noise(raw_noise)

    update(health: health)
  end

  # Display the historical value of economy between two dates
  def self.history(from, to)
    starting_step = self.date_to_step(from)
    final_step = self.date_to_step(to)

    # Query the noise values between the dates and normalize them for economy values
    NoiseService.step_range(SEED, starting_step, final_step).map { |i| self.normalize_noise(i) }
  end

  private

  # All steps are counted as days from 2000
  def self.date_to_step(date)
    (date - Date.new(2000)).to_i
  end

  # Clamp noise to a range of 0 to 1000
  def self.normalize_noise(noise)
    MathService.clamp(noise * 1000, 0, 1000).to_i
  end
end
