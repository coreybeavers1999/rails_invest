# frozen_string_literal: true

require "perlin"

class NoiseService
  LOCKED_Y = 2.1
  NOISE_PARAMS = {
    economy: {
      persistence: 0.5,
      octaves: 3,
      scale: 0.01
    },
    industry: {
      persistence: 0.1,
      octaves: 1,
      scale: 0.05
    },
    company: {
      persistence: 0.1,
      octaves: 1,
      scale: 0.05
    }
  }.freeze

  # Returns a single float value at the given step
  # @param noise_params [Hash] noise parameters. Collected from NOISE_PARAMS except for companies
  # @return [Float] normalized between 0.0 - 1.0
  def self.step_value(
    seed,
    step,
    noise_params: NOISE_PARAMS[:economy],
    generator: nil
  )
    # Create noise object unless one is provided.
    # I can't use the generator.chunk method because of rounding point errors in the C code.
    # To improve performance, I can reuse a single instance of Perlin::Generator.
    generator = Perlin::Generator.new(seed, noise_params[:persistence], noise_params[:octaves]) unless generator
    normalize(generator[step * noise_params[:scale], LOCKED_Y])
  end

  # Returns a flat array of noise values between the given steps
  # @return [Array<Float>] normalized between 0.0 - 1.0
  def self.step_range(seed, step_start, step_end, noise_params: NOISE_PARAMS[:economy])
    # Less efficient, but stable solution around rounding error.
    generator = Perlin::Generator.new(seed, noise_params[:persistence], noise_params[:octaves])

    # Iterate over each step and generate a noise value using step_value and passing the generator.
    (step_start..step_end).map do |step|
      self.step_value(seed, step, noise_params: noise_params, generator: generator)
    end

    # This is the gem's recommended appoach to gathering chunks of data.
    # Unfortunately, the gem's chunk method has rounding point errors in the C code.
    # gen = Perlin::Generator.new(seed, noise_params[:persistence], noise_params[:octaves])
    # width = step_end - step_start + 1
    # noise = gen.chunk(step_start * noise_params[:scale], LOCKED_Y, width, 1, noise_params[:scale])
    # noise.flatten.map { |i| normalize(i) }
  end

  private

  def self.normalize(v)
    (v + 1) / 2
  end
end
