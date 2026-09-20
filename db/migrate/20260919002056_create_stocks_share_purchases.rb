class CreateStocksSharePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_share_purchases do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :company, null: false, foreign_key: { to_table: :stocks_companies }
      t.integer :count
      t.decimal :share_price, precision: 20, scale: 2

      t.timestamps
    end
  end
end
