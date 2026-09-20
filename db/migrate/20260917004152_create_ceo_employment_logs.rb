class CreateCeoEmploymentLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_ceo_employment_logs do |t|
      t.references :ceo, null: false, foreign_key: { to_table: :stocks_ceos }
      t.references :company, null: false, foreign_key: { to_table: :stocks_companies }
      t.date :started_on, null: false, default: -> { 'CURRENT_DATE' }
      t.date :ended_on
      t.string :departure_status

      t.timestamps
    end
  end
end
