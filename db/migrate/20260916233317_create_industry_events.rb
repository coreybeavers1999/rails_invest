class CreateIndustryEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_industry_events do |t|
      t.references :industry, null: false, foreign_key: { to_table: :stocks_industries }
      t.integer :new_direction, null: false, comment: "What is the new direction of the industry?"
      t.boolean :public, null: false, default: false, comment: "Is a news article created for this event?"

      t.timestamps
    end
  end
end
