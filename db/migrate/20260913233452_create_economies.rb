class CreateEconomies < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_economies do |t|
      t.integer :health, null: false, default: 500, comment: "Range (0, 1000): Applies as dampener to industry health, nightly"

      t.timestamps
    end

    add_check_constraint :stocks_economies, "health >= 0 AND health <= 1000", name: "economies_health_range"
    add_check_constraint :stocks_economies, "id = 1", name: "economies_singleton_id"
  end
end
