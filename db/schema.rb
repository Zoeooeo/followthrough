# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.

ActiveRecord::Schema[7.2].define(version: 2026_11_06_000005) do
  create_table "care_concerns", force: :cascade do |t|
    t.integer "resident_id", null: false
    t.integer "signal_item_id"
    t.string "title", null: false
    t.text "fixed_goal", null: false
    t.string "opened_by", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resident_id"], name: "index_care_concerns_on_resident_id"
    t.index ["signal_item_id"], name: "index_care_concerns_on_signal_item_id"
    t.index ["status"], name: "index_care_concerns_on_status"
  end

  create_table "rechecks", force: :cascade do |t|
    t.integer "care_concern_id", null: false
    t.string "checked_by", null: false
    t.string "result", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["care_concern_id"], name: "index_rechecks_on_care_concern_id"
  end

  create_table "residents", force: :cascade do |t|
    t.string "name", null: false
    t.string "facility"
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signal_items", force: :cascade do |t|
    t.integer "resident_id", null: false
    t.string "need", null: false
    t.text "shows_by", null: false
    t.text "check_for", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resident_id"], name: "index_signal_items_on_resident_id"
  end

  create_table "staff_responses", force: :cascade do |t|
    t.integer "care_concern_id", null: false
    t.string "staff_name", null: false
    t.text "statement", null: false
    t.date "said_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["care_concern_id"], name: "index_staff_responses_on_care_concern_id"
  end

  add_foreign_key "care_concerns", "residents"
  add_foreign_key "care_concerns", "signal_items", on_delete: :nullify
  add_foreign_key "rechecks", "care_concerns"
  add_foreign_key "signal_items", "residents"
  add_foreign_key "staff_responses", "care_concerns"
end
