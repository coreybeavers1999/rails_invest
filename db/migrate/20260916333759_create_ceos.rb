class CreateCeos < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks_ceos do |t|
      t.string :name, null: false, index: { unique: true }
      t.references :company,
                   null: true, foreign_key: { to_table: :stocks_companies }, index: { unique: true }
      t.integer :skill, null: false, default: 50, comment: "Range (0-100): Used to determine company event direction_deltas. Normalized to [-50, 50]"
      t.integer :controversial, null: false, default: 50, comment: "Range (0-100): Used to determine company event frequency. Higher = more frequent events"

      t.date :retires_at,
             null: false,
             default: -> { "CURRENT_DATE + (floor(180 * random()) + 180)::integer" },
             comment: "Range (today + 180-360 days): Date the ceo will retire, defaults to a random date between 180 and 360 days from today"

      t.boolean :retired, default: false, null: false

      t.timestamps
    end

    add_check_constraint :stocks_ceos, "skill >= 0 AND skill <= 100", name: "ceos_skill_range"
    add_check_constraint :stocks_ceos, "controversial >= 0 AND controversial <= 100", name: "ceos_controversial_range"
    add_check_constraint :stocks_ceos, "retires_at >= created_at::date + 180 and retires_at <= created_at::date + 360", name: "ceos_retires_at_range"
  end
end
