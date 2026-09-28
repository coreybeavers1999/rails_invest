class CreateStocksIndustrySnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_industry_snapshots do |t|
      # Turned off index for industry because composite index added with recorded_on makes this redundant
      t.references :industry, null: false, index: false, foreign_key: { to_table: :stocks_industries }
      t.date :recorded_on, null: false, comment: "The date the snapshot was recorded"
      t.integer :health, null: false, comment: "The health of the industry on the given date"
      t.integer :direction, null: false, comment: "The direction of the industry at the given date. Only updated via event"
      t.integer :delta, null: false, comment: "The change in health from the previous snapshot"

      t.references :industry_event,
                   null: true,
                   default: nil,
                   foreign_key: { to_table: :stocks_industry_events },
                   index: { unique: true },
                   comment: "If an industry event was created on this day, a reference to it will be stored here"

      t.timestamps
    end

    # Nearly every time we fetch snapshots from the database, it will be based off a specific industry
    # and a date range (or at least always ordered by a date range). This composite index will help speed
    # up those queries.

    add_index :stocks_industry_snapshots,
              [ :industry_id, :recorded_on ],
              unique: true,
              name: "index_industry_snapshots_on_industry_id_and_recorded_on"
  end
end
