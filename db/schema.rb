# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.

ActiveRecord::Schema[7.2].define(version: 2026_11_22_000006) do
  create_table "care_concerns", force: :cascade do |t|
    t.integer "resident_id", null: false
    t.integer "signal_item_id"
    t.string "title", null: false
    t.text "fixed_goal", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_to_id"
    t.integer "visit_id"
    t.integer "opened_by_id", null: false
    t.index ["assigned_to_id"], name: "index_care_concerns_on_assigned_to_id"
    t.index ["opened_by_id"], name: "index_care_concerns_on_opened_by_id"
    t.index ["resident_id"], name: "index_care_concerns_on_resident_id"
    t.index ["signal_item_id"], name: "index_care_concerns_on_signal_item_id"
    t.index ["status"], name: "index_care_concerns_on_status"
    t.index ["visit_id"], name: "index_care_concerns_on_visit_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "resident_id", null: false
    t.string "role", default: "relative", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resident_id"], name: "index_memberships_on_resident_id"
    t.index ["user_id", "resident_id"], name: "index_memberships_on_user_id_and_resident_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "rechecks", force: :cascade do |t|
    t.integer "care_concern_id", null: false
    t.string "result", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "checked_by_id", null: false
    t.index ["care_concern_id"], name: "index_rechecks_on_care_concern_id"
    t.index ["checked_by_id"], name: "index_rechecks_on_checked_by_id"
  end

  create_table "residents", force: :cascade do |t|
    t.string "name", null: false
    t.string "facility"
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invite_code", null: false
    t.index ["invite_code"], name: "index_residents_on_invite_code", unique: true
  end

  create_table "signal_items", force: :cascade do |t|
    t.integer "resident_id", null: false
    t.string "need", null: false
    t.text "shows_by", null: false
    t.text "check_for", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.index ["resident_id"], name: "index_signal_items_on_resident_id"
    t.index ["updated_by_id"], name: "index_signal_items_on_updated_by_id"
  end

  create_table "signal_items_visits", id: false, force: :cascade do |t|
    t.integer "signal_item_id", null: false
    t.integer "visit_id", null: false
    t.index ["signal_item_id"], name: "index_signal_items_visits_on_signal_item_id"
    t.index ["visit_id", "signal_item_id"], name: "index_signal_items_visits_on_visit_id_and_signal_item_id", unique: true
  end

  create_table "staff_responses", force: :cascade do |t|
    t.integer "care_concern_id", null: false
    t.string "staff_name", null: false
    t.text "statement", null: false
    t.date "said_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recorded_by_id"
    t.index ["care_concern_id"], name: "index_staff_responses_on_care_concern_id"
    t.index ["recorded_by_id"], name: "index_staff_responses_on_recorded_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.integer "resident_id", null: false
    t.integer "user_id", null: false
    t.date "visited_on", null: false
    t.string "mood", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resident_id"], name: "index_visits_on_resident_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "care_concerns", "residents"
  add_foreign_key "care_concerns", "signal_items", on_delete: :nullify
  add_foreign_key "care_concerns", "users", column: "assigned_to_id"
  add_foreign_key "care_concerns", "users", column: "opened_by_id"
  add_foreign_key "care_concerns", "visits", on_delete: :nullify
  add_foreign_key "memberships", "residents"
  add_foreign_key "memberships", "users"
  add_foreign_key "rechecks", "care_concerns"
  add_foreign_key "rechecks", "users", column: "checked_by_id"
  add_foreign_key "signal_items", "residents"
  add_foreign_key "signal_items", "users", column: "updated_by_id"
  add_foreign_key "staff_responses", "care_concerns"
  add_foreign_key "staff_responses", "users", column: "recorded_by_id"
  add_foreign_key "visits", "residents"
  add_foreign_key "visits", "users"
end
