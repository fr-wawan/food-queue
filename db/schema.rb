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

ActiveRecord::Schema[8.1].define(version: 2026_04_26_004153) do
  create_table "menu_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "menu_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "stock", default: 0
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_menu_items_on_menu_id"
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menus_on_restaurant_id"
  end

  create_table "order_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "menu_item_id", null: false
    t.bigint "order_id", null: false
    t.integer "quantity", null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "note"
    t.string "order_number", null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["restaurant_id"], name: "index_orders_on_restaurant_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "restaurants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_restaurants_on_slug", unique: true
    t.index ["subdomain"], name: "index_restaurants_on_subdomain", unique: true
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.string "jti", null: false
    t.string "token_digest"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["jti"], name: "index_sessions_on_jti", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.bigint "restaurant_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email", "restaurant_id"], name: "index_users_on_email_and_restaurant_id", unique: true
    t.index ["restaurant_id"], name: "index_users_on_restaurant_id"
  end

  add_foreign_key "menu_items", "menus"
  add_foreign_key "menu_items", "restaurants"
  add_foreign_key "menus", "restaurants"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "restaurants"
  add_foreign_key "orders", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "restaurants"
end
