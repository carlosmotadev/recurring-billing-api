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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_143410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "email", null: false
    t.string "name", null: false
    t.string "stripe_customer_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["stripe_customer_id"], name: "index_customers_on_stripe_customer_id", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.datetime "paid_at"
    t.integer "status"
    t.string "stripe_invoice_id"
    t.bigint "subscription_id", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "interval", default: 0, null: false
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "stripe_price_id"
    t.datetime "updated_at", null: false
    t.index ["stripe_price_id"], name: "index_plans_on_stripe_price_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.bigint "customer_id", null: false
    t.bigint "plan_id", null: false
    t.integer "status"
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "subscriptions", "customers"
  add_foreign_key "subscriptions", "plans"
end
