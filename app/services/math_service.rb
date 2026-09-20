# frozen_string_literal: true

class MathService

  # Returns the value clamped between min and max range
  def self.clamp(value, min, max)
    [ min, [ value, max ].min ].max
  end
end
