class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_companies do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :acronym, null: false, index: { unique: true }
      t.text :description
      t.references :industry, null: false, foreign_key: { to_table: :stocks_industries }
      t.decimal :value, precision: 20, scale: 2, comment: 'Company value in USD'
      t.integer :shares_issued, null: false, comment: 'Number of shares issued'
      t.integer :direction, null: false, default: 50, comment: 'Range (0, 100): Applied to value at nightly reset. Normalized to (-50, 50)'
      t.decimal :bankrupts_at, precision: 20, scale: 2, comment: 'If the value of the company reaches this threshold, the company goes bankrupt'
      t.integer :fires_ceo_at, null: false, comment: 'If the CEO cumulative direction delta reaches this threshold, the CEO is fired'
      t.integer :ceo_cumulative_direction_delta, null: false, default: 0, comment: 'Net direction delta applied since the current CEO was hired. Each night cumulatively adds until the CEO is fired'
      t.integer :seed, null: false

      t.timestamps
    end

    add_check_constraint :stocks_companies, "value > 0.00", name: "company_value_positive"
    add_check_constraint :stocks_companies, "shares_issued > 0", name: "company_shares_issued_positive"
    add_check_constraint :stocks_companies, "bankrupts_at > 0.00", name: "company_bankrupts_at_positive"
  end
end
