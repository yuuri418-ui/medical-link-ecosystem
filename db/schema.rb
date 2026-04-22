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

ActiveRecord::Schema[7.1].define(version: 2026_04_04_021338) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blood_test_items", force: :cascade do |t|
    t.bigint "visit_log_id", null: false
    t.string "name"
    t.float "value"
    t.string "unit"
    t.string "reference_range"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_log_id"], name: "index_blood_test_items_on_visit_log_id"
  end

  create_table "blood_test_results", force: :cascade do |t|
    t.bigint "visit_log_id", null: false
    t.string "item_name"
    t.float "value"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_log_id"], name: "index_blood_test_results_on_visit_log_id"
  end

  create_table "daily_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.integer "stiffness_duration", default: 0
    t.integer "pain_vas", default: 0
    t.integer "fatigue_vas", default: 0
    t.integer "condition", default: 3, null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "pain_parts"
    t.index ["user_id", "date"], name: "index_daily_logs_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_logs_on_user_id"
  end

  create_table "medication_logs", force: :cascade do |t|
    t.bigint "daily_log_id", null: false
    t.string "medicine_name"
    t.string "dosage"
    t.boolean "is_taken"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "english_name"
    t.index ["daily_log_id"], name: "index_medication_logs_on_daily_log_id"
  end

  create_table "prescribed_medicines", force: :cascade do |t|
    t.bigint "visit_log_id", null: false
    t.string "name"
    t.string "dosage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_log_id"], name: "index_prescribed_medicines_on_visit_log_id"
  end

  create_table "temperature_logs", force: :cascade do |t|
    t.bigint "daily_log_id", null: false
    t.datetime "measured_at"
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_log_id"], name: "index_temperature_logs_on_daily_log_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.string "last_name_kana", null: false
    t.string "first_name_kana", null: false
    t.integer "gender", default: 0, null: false
    t.date "birthday", null: false
    t.string "phone_number", null: false
    t.string "diagnosis_name"
    t.date "started_at"
    t.string "patient_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "visited_on"
    t.string "hospital_name"
    t.string "department"
    t.string "doctor_name"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_visit_logs_on_user_id"
  end

  add_foreign_key "blood_test_items", "visit_logs"
  add_foreign_key "blood_test_results", "visit_logs"
  add_foreign_key "daily_logs", "users"
  add_foreign_key "medication_logs", "daily_logs"
  add_foreign_key "prescribed_medicines", "visit_logs"
  add_foreign_key "temperature_logs", "daily_logs"
  add_foreign_key "visit_logs", "users"
end
