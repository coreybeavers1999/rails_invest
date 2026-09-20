class CreateIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_industries do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :health, null: false, default: 500, comment: "Range (0-1000): Directly applied to sub company's value nightly"
      t.integer :direction, null: false, default: 0, comment: "Added to current health every nightly update. Updated by industry events"
      t.integer :event_chance, null: false, default: 3, comment: "Range (0-100): Chance of an industry event occurring nightly"
      t.integer :seed, null: false

      t.timestamps
    end

    add_check_constraint :stocks_industries, "health >= 0 AND health <= 1000", name: "industries_health_range"
    add_check_constraint :stocks_industries, "event_chance >= 0 AND event_chance <= 100", name: "industries_event_chance_range"
  end
end
