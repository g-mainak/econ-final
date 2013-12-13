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

ActiveRecord::Schema.define(version: 20131208182719) do

  create_table "skus", force: true do |t|
    t.string   "sale_name"
    t.datetime "begin_time"
    t.datetime "end_time"
    t.string   "interval"
    t.string   "product_name"
    t.string   "product_brand"
    t.string   "product_content"
    t.integer  "initial_count"
    t.integer  "final_count"
    t.float    "msrp"
    t.float    "sale"
    t.string   "sku_attributes"
    t.string   "sale_id"
    t.integer  "product_id"
    t.integer  "sku_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skus", ["product_id", "sku_id"], name: "index_skus_on_product_id_and_sku_id", unique: true

end
