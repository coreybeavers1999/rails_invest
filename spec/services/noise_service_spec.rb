require 'rails_helper'

RSpec.describe NoiseService do
  let(:seed) { 1 }
  let(:noise_params) { NoiseService::NOISE_PARAMS[:economy] }

  it "has deterministic noise" do
    # Two samples of step value
    first = NoiseService.step_value(seed, 1, noise_params: noise_params)
    second = NoiseService.step_value(seed, 1, noise_params: noise_params)
    expect(first).to eq(second)

    # Sample of step value and step range
    first = NoiseService.step_value(seed, 1, noise_params: noise_params)
    second = NoiseService.step_range(seed, 1, 1, noise_params: noise_params)
    expect(first).to eq(second[0])

    # Two ranges with overlap
    first = NoiseService.step_range(seed, 0, 20, noise_params: noise_params)
    second = NoiseService.step_range(seed, 10, 30, noise_params: noise_params)

    # Zip the two sets of numbers by their mutual range overlap
    compared = first.slice(10, 10).zip(second.slice(0, 10))

    # Check if any mismatches
    expect(compared.all? { |(a, b)| a == b }).to be true
  end

  it "has normalized value between 0.0 - 1.0" do
    # Generate single value and a range of values
    value = NoiseService.step_value(seed, 1, noise_params: noise_params)
    range_values = NoiseService.step_range(seed, 1, 100, noise_params: noise_params)
    any_out_of_range = range_values.any? { |v| v < 0.0 || v > 1.0 }

    expect(value).to be_between(0.0, 1.0)
    expect(any_out_of_range).to be false
  end
end
