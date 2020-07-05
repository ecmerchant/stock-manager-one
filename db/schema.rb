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

ActiveRecord::Schema.define(version: 2020_07_05_035353) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "new_password"
    t.string "new_password_confirmation"
  end

  create_table "codes", force: :cascade do |t|
    t.string "category"
    t.string "number"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "user"
    t.string "asin"
    t.string "key"
    t.integer "input_price"
    t.float "sell_price"
    t.string "title"
    t.string "url"
    t.string "condition"
    t.string "ebay_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "user"
    t.string "item_id"
    t.text "title"
    t.float "price"
    t.string "shipping"
    t.string "item_url"
    t.text "item_specs"
    t.string "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "condition"
    t.index ["user", "group_id", "item_id"], name: "product_upsert", unique: true
  end

  create_table "search_conditions", force: :cascade do |t|
    t.string "user"
    t.string "app_id"
    t.integer "low_price"
    t.integer "high_price"
    t.string "category_id"
    t.string "item_condition"
    t.string "sales_type"
    t.string "rank"
    t.string "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "handling_time"
  end

  create_table "search_groups", force: :cascade do |t|
    t.string "user"
    t.string "group_id"
    t.text "query"
    t.integer "low_price"
    t.integer "high_price"
    t.string "category_id"
    t.string "item_condition"
    t.string "sales_type"
    t.string "rank"
    t.string "score"
    t.integer "handling_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "search_keys", force: :cascade do |t|
    t.string "user"
    t.string "asin"
    t.string "key"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "stock_id"
    t.datetime "store_date"
    t.datetime "ship_date"
    t.float "purchase_price"
    t.string "purchase_shop"
    t.string "brand"
    t.string "product_id"
    t.string "box"
    t.string "manual"
    t.string "tag"
    t.text "other1"
    t.text "other2"
    t.string "paper_check"
    t.string "condition"
    t.text "note"
    t.text "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "place"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_flg"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
