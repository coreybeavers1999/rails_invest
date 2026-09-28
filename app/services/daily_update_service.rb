# frozen_string_literal: true

class Stocks::DailyUpdateService
  def initialize(date: nil)
    @date = date || Date.current
  end

  def call
    update_economy
    update_industries
  end


  private

  def update_economy
    @economy = Stocks::Economy.find_or_create_by(id: 1)
    @economy.daily_update(@date)
  end

  def update_industries
    Stocks::Industry.find_each { |industry| industry.daily_update(@economy, @date) }
  end
end
