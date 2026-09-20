# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_19_002056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "stocks_ceo_employment_logs", force: :cascade do |t|
    t.bigint "ceo_id", null: false
    t.bigint "company_id", null: false
    t.date "started_on", default: -> { "CURRENT_DATE" }, null: false
    t.date "ended_on"
    t.string "departure_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ceo_id"], name: "index_stocks_ceo_employment_logs_on_ceo_id"
    t.index ["company_id"], name: "index_stocks_ceo_employment_logs_on_company_id"
  end

  create_table "stocks_ceos", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id"
    t.integer "skill", default: 50, null: false, comment: "Range (0-100): Used to determine company event direction_deltas. Normalized to [-50, 50]"
    t.integer "controversial", default: 50, null: false, comment: "Range (0-100): Used to determine company event frequency. Higher = more frequent events"
    t.date "retires_at", default: -> { "(CURRENT_DATE + ((floor(((180)::double precision * random())) + (180)::double precision))::integer)" }, null: false, comment: "Range (today + 180-360 days): Date the ceo will retire, defaults to a random date between 180 and 360 days from today"
    t.boolean "retired", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_stocks_ceos_on_company_id", unique: true
    t.index ["name"], name: "index_stocks_ceos_on_name", unique: true
    t.check_constraint "controversial >= 0 AND controversial <= 100", name: "ceos_controversial_range"
    t.check_constraint "retires_at >= (created_at::date + 180) AND retires_at <= (created_at::date + 360)", name: "ceos_retires_at_range"
    t.check_constraint "skill >= 0 AND skill <= 100", name: "ceos_skill_range"
  end

  create_table "stocks_companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "acronym", null: false
    t.text "description"
    t.bigint "industry_id", null: false
    t.decimal "value", precision: 20, scale: 2, comment: "Company value in USD"
    t.integer "shares_issued", null: false, comment: "Number of shares issued"
    t.integer "direction", default: 50, null: false, comment: "Range (0, 100): Applied to value at nightly reset. Normalized to (-50, 50)"
    t.decimal "bankrupts_at", precision: 20, scale: 2, comment: "If the value of the company reaches this threshold, the company goes bankrupt"
    t.integer "fires_ceo_at", null: false, comment: "If the CEO cumulative direction delta reaches this threshold, the CEO is fired"
    t.integer "ceo_cumulative_direction_delta", default: 0, null: false, comment: "Net direction delta applied since the current CEO was hired. Each night cumulatively adds until the CEO is fired"
    t.integer "seed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acronym"], name: "index_stocks_companies_on_acronym", unique: true
    t.index ["industry_id"], name: "index_stocks_companies_on_industry_id"
    t.index ["name"], name: "index_stocks_companies_on_name", unique: true
    t.check_constraint "bankrupts_at > 0.00", name: "company_bankrupts_at_positive"
    t.check_constraint "shares_issued > 0", name: "company_shares_issued_positive"
    t.check_constraint "value > 0.00", name: "company_value_positive"
  end

  create_table "stocks_company_events", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.integer "direction_delta", null: false, comment: "Delta added to current company direction"
    t.boolean "public", default: false, null: false, comment: "Is a news article created for this event?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_stocks_company_events_on_company_id"
  end

  create_table "stocks_economies", force: :cascade do |t|
    t.integer "health", default: 500, null: false, comment: "Range (0, 1000): Applies as dampener to industry health, nightly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "health >= 0 AND health <= 1000", name: "economies_health_range"
    t.check_constraint "id = 1", name: "economies_singleton_id"
  end

  create_table "stocks_industries", force: :cascade do |t|
    t.string "name", null: false
    t.integer "health", default: 500, null: false, comment: "Range (0-1000): Directly applied to sub company's value nightly"
    t.integer "direction", default: 0, null: false, comment: "Added to current health every nightly update. Updated by industry events"
    t.integer "event_chance", default: 3, null: false, comment: "Range (0-100): Chance of an industry event occurring nightly"
    t.integer "seed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_stocks_industries_on_name", unique: true
    t.check_constraint "event_chance >= 0 AND event_chance <= 100", name: "industries_event_chance_range"
    t.check_constraint "health >= 0 AND health <= 1000", name: "industries_health_range"
  end

  create_table "stocks_industry_events", force: :cascade do |t|
    t.bigint "industry_id", null: false
    t.integer "direction_delta", null: false, comment: "Delta added to current industry direction"
    t.boolean "public", default: false, null: false, comment: "Is a news article created for this event?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_stocks_industry_events_on_industry_id"
  end

  create_table "stocks_share_purchases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.integer "count"
    t.decimal "share_price", precision: 20, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_stocks_share_purchases_on_company_id"
    t.index ["user_id"], name: "index_stocks_share_purchases_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "stocks_ceo_employment_logs", "stocks_ceos", column: "ceo_id"
  add_foreign_key "stocks_ceo_employment_logs", "stocks_companies", column: "company_id"
  add_foreign_key "stocks_ceos", "stocks_companies", column: "company_id"
  add_foreign_key "stocks_companies", "stocks_industries", column: "industry_id"
  add_foreign_key "stocks_company_events", "stocks_companies", column: "company_id"
  add_foreign_key "stocks_industry_events", "stocks_industries", column: "industry_id"
  add_foreign_key "stocks_share_purchases", "stocks_companies", column: "company_id"
  add_foreign_key "stocks_share_purchases", "users"
end
