class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @all_industries_chart = {
      title: "All Industries - Last Year",
      series: Stocks::Industry.order(:name).map do |industry|
        {
          url: industry_history_stock_path(industry.id, from: 1.years.ago.to_date.iso8601, to: Date.current.iso8601),
          name: industry.name
        }
      end + [
        {
          url: economy_history_stocks_path(from: 1.years.ago.to_date.iso8601, to: Date.current.iso8601),
          name: "Global Economy"
        }
      ]
    }

    @industries = Stocks::Industry.order(:name).map do |industry|
      {
        title: "#{industry.name} - Last Year",
        series: [
          {
            url: industry_history_stock_path(industry.id, from: 1.years.ago.to_date.iso8601, to: Date.current.iso8601),
            name: industry.name
          },
          {
            url: economy_history_stocks_path(from: 1.years.ago.to_date.iso8601, to: Date.current.iso8601),
            name: "Global Economy"
          }
        ]
      }
    end
  end
end
