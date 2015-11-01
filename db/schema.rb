# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151101144153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "due_last_invoice", precision: 10, scale: 2
    t.integer "household_id", null: false
    t.integer "last_invoice_id"
    t.date "last_invoiced_on"
    t.decimal "total_new_charges", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal "total_new_credits", precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "accounts", ["household_id"], name: "index_accounts_on_household_id", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "meal_id", null: false
    t.boolean "notified", default: false, null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
  end

  add_index "assignments", ["meal_id", "role", "user_id"], name: "index_assignments_on_meal_id_and_role_and_user_id", unique: true, using: :btree
  add_index "assignments", ["meal_id"], name: "index_assignments_on_meal_id", using: :btree
  add_index "assignments", ["notified"], name: "index_assignments_on_notified", using: :btree
  add_index "assignments", ["role"], name: "index_assignments_on_role", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string "abbrv", limit: 2
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "settings", default: "{}"
    t.datetime "updated_at", null: false
  end

  add_index "communities", ["abbrv"], name: "index_communities_on_abbrv", unique: true, using: :btree
  add_index "communities", ["name"], name: "index_communities_on_name", unique: true, using: :btree

  create_table "credit_limits", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.boolean "exceeded", default: false, null: false
    t.integer "household_id", null: false
    t.datetime "updated_at", null: false
  end

  add_index "credit_limits", ["community_id"], name: "index_credit_limits_on_community_id", using: :btree
  add_index "credit_limits", ["household_id"], name: "index_credit_limits_on_household_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at"
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at"
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "formulas", force: :cascade do |t|
    t.decimal "adult_meat", precision: 5, scale: 3
    t.decimal "adult_veg", precision: 5, scale: 3
    t.decimal "big_kid_meat", precision: 5, scale: 3
    t.decimal "big_kid_veg", precision: 5, scale: 3
    t.integer "community_id", null: false
    t.date "effective_on", null: false
    t.decimal "little_kid_meat", precision: 5, scale: 3
    t.decimal "little_kid_veg", precision: 5, scale: 3
    t.string "meal_calc_type", null: false
    t.string "pantry_calc_type"
    t.decimal "pantry_fee", precision: 5, scale: 3
    t.decimal "senior_meat", precision: 5, scale: 3
    t.decimal "senior_veg", precision: 5, scale: 3
    t.decimal "teen_meat", precision: 5, scale: 3
    t.decimal "teen_veg", precision: 5, scale: 3
  end

  add_index "formulas", ["community_id"], name: "index_formulas_on_community_id", using: :btree
  add_index "formulas", ["effective_on"], name: "index_formulas_on_effective_on", using: :btree

  create_table "households", force: :cascade do |t|
    t.integer "community_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "name", limit: 50, null: false
    t.integer "old_id"
    t.string "old_name"
    t.string "unit_num"
    t.datetime "updated_at", null: false
  end

  add_index "households", ["community_id", "name"], name: "index_households_on_community_id_and_name", unique: true, using: :btree
  add_index "households", ["community_id"], name: "index_households_on_community_id", using: :btree
  add_index "households", ["deactivated_at"], name: "index_households_on_deactivated_at", using: :btree
  add_index "households", ["name"], name: "index_households_on_name", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "meal_id", null: false
  end

  add_index "invitations", ["community_id", "meal_id"], name: "index_invitations_on_community_id_and_meal_id", unique: true, using: :btree
  add_index "invitations", ["community_id"], name: "index_invitations_on_community_id", using: :btree
  add_index "invitations", ["meal_id"], name: "index_invitations_on_meal_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "due_on", null: false
    t.integer "household_id", null: false
    t.decimal "prev_balance", precision: 10, scale: 3, null: false
    t.decimal "total_due", precision: 10, scale: 3, null: false
    t.datetime "updated_at", null: false
  end

  add_index "invoices", ["due_on"], name: "index_invoices_on_due_on", using: :btree
  add_index "invoices", ["household_id"], name: "index_invoices_on_household_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 3, null: false
    t.string "code", limit: 16, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, null: false
    t.integer "household_id", null: false
    t.date "incurred_on", null: false
    t.integer "invoice_id"
    t.integer "invoiceable_id"
    t.string "invoiceable_type", limit: 32
    t.datetime "updated_at", null: false
  end

  add_index "line_items", ["code"], name: "index_line_items_on_code", using: :btree
  add_index "line_items", ["household_id"], name: "index_line_items_on_household_id", using: :btree
  add_index "line_items", ["incurred_on"], name: "index_line_items_on_incurred_on", using: :btree
  add_index "line_items", ["invoice_id"], name: "index_line_items_on_invoice_id", using: :btree
  add_index "line_items", ["invoiceable_id", "invoiceable_type"], name: "index_line_items_on_invoiceable_id_and_invoiceable_type", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string "abbrv", limit: 8, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_index "locations", ["abbrv"], name: "index_locations_on_abbrv", unique: true, using: :btree
  add_index "locations", ["name"], name: "index_locations_on_name", unique: true, using: :btree

  create_table "meals", force: :cascade do |t|
    t.text "allergens", default: "[]", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.text "dessert"
    t.decimal "discount", precision: 5, scale: 2, default: 0.0, null: false
    t.text "entrees"
    t.integer "host_community_id", null: false
    t.text "kids"
    t.integer "location_id"
    t.text "notes"
    t.datetime "served_at", null: false
    t.text "side"
    t.string "status", default: "open", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  add_index "meals", ["location_id"], name: "index_meals_on_location_id", using: :btree
  add_index "meals", ["served_at"], name: "index_meals_on_served_at", using: :btree

  create_table "signups", force: :cascade do |t|
    t.integer "adult_meat", default: 0, null: false
    t.integer "adult_veg", default: 0, null: false
    t.integer "big_kid_meat", default: 0, null: false
    t.integer "big_kid_veg", default: 0, null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.integer "household_id", null: false
    t.integer "little_kid_meat", default: 0, null: false
    t.integer "little_kid_veg", default: 0, null: false
    t.integer "meal_id", null: false
    t.boolean "notified", default: false, null: false
    t.integer "senior_meat", default: 0, null: false
    t.integer "senior_veg", default: 0, null: false
    t.integer "teen_meat", default: 0, null: false
    t.integer "teen_veg", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "signups", ["household_id", "meal_id"], name: "index_signups_on_household_id_and_meal_id", unique: true, using: :btree
  add_index "signups", ["household_id"], name: "index_signups_on_household_id", using: :btree
  add_index "signups", ["meal_id"], name: "index_signups_on_meal_id", using: :btree
  add_index "signups", ["notified"], name: "index_signups_on_notified", using: :btree

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "alternate_id"
    t.boolean "biller", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.datetime "deactivated_at"
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "google_email"
    t.string "home_phone"
    t.integer "household_id", null: false
    t.string "last_name", null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.string "mobile_phone"
    t.string "provider"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "work_phone"
  end

  add_index "users", ["alternate_id"], name: "index_users_on_alternate_id", using: :btree
  add_index "users", ["deactivated_at"], name: "index_users_on_deactivated_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["google_email"], name: "index_users_on_google_email", unique: true, using: :btree
  add_index "users", ["household_id"], name: "index_users_on_household_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "accounts", "households"
  add_foreign_key "accounts", "invoices", column: "last_invoice_id"
  add_foreign_key "assignments", "meals"
  add_foreign_key "assignments", "users"
  add_foreign_key "credit_limits", "communities"
  add_foreign_key "credit_limits", "households"
  add_foreign_key "formulas", "communities"
  add_foreign_key "households", "communities"
  add_foreign_key "invitations", "communities"
  add_foreign_key "invitations", "meals"
  add_foreign_key "invoices", "households"
  add_foreign_key "line_items", "households"
  add_foreign_key "line_items", "invoices"
  add_foreign_key "meals", "communities", column: "host_community_id"
  add_foreign_key "meals", "locations"
  add_foreign_key "signups", "households"
  add_foreign_key "signups", "meals"
  add_foreign_key "users", "households"
end
