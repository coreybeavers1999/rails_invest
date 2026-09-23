# frozen_string_literal: true

require "perlin"

class NoiseService
  LOCKED_Y = 2.1
  PERSISTENCE = 0.1
  OCTAVES = 1
  SCALE = 0.05

  # Returns a single float value at the given step
  # @return [Float] normalized between 0.0 - 1.0
  def self.step_value(seed, step)
    # Create noise object
    noise = Perlin::Generator.new(seed, PERSISTENCE, OCTAVES)
    noise[step * SCALE, LOCKED_Y]
  end

  # Returns a flat array of noise values between the given steps
  # @return [Array<Float>] normalized between 0.0 - 1.0
  def self.step_range(seed, step_start, step_end)
    gen = Perlin::Generator.new(seed, PERSISTENCE, OCTAVES)
    width = step_end - step_start + 1
    noise = gen.chunk(step_start * SCALE, LOCKED_Y, width, 1, SCALE)
    noise.flatten.map { |i| normalize(i) }
  end

  private

  def self.normalize(v)
    (v + 1) / 2
  end
end
