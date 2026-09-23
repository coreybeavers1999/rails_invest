# frozen_string_literal: true

class StocksController < ApplicationController
  before_action :authenticate_user!

  def index
    @economy_current = Stocks::Economy.first.value
  end

  def economy_history
    # Parse from and to as dates
    from = string_to_date(params[:from])
    to = string_to_date(params[:to])

    # If either is invalid, render unprocessable
    if from.nil? || to.nil? || from > to
      render status: :unprocessable_entity, json: { error: "Invalid date range" }
      return
    end

    # Fetch economy history
    economy_history = Stocks::Economy.history(from, to)

    render status: :ok, json: economy_history
  end

  private

  # Attempts to parse a string as a date. Returns nil if invalid
  def string_to_date(str)
    # If string isn't present, return current date
    return Date.current unless str.present?

    # Try to parse string as date
    Date.iso8601(str)
  rescue ArgumentError
    nil
  end
end
