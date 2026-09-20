class CreateCompanyEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_company_events do |t|
      t.references :company, null: false, foreign_key: {  to_table: :stocks_companies }
      t.integer :direction_delta, null: false, comment: "Delta added to current company direction"
      t.boolean :public, null: false, default: false, comment: "Is a news article created for this event?"

      t.timestamps
    end
  end
end
