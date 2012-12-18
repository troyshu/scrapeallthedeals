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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121218214528) do

  create_table "deals", :force => true do |t|
    t.integer  "external_id"
    t.string   "site"
    t.string   "name"
    t.string   "headline"
    t.string   "picture"
    t.date     "expiration"
    t.string   "url"
    t.string   "deal_type"
    t.float    "price"
    t.float    "savings"
    t.string   "location"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "static_location"
    t.string   "predicted_deal_type"
    t.float    "nb_diff"
  end

  add_index "deals", ["external_id"], :name => "index_deals_on_external_id"

  create_table "training_deals", :force => true do |t|
    t.integer  "deal_id"
    t.string   "deal_type"
    t.string   "deal_headline"
    t.string   "url"
    t.boolean  "trained"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "predicted_deal_type"
  end

  add_index "training_deals", ["deal_id"], :name => "index_training_deals_on_deal_id"

  create_table "word_counts", :force => true do |t|
    t.string   "word"
    t.string   "category"
    t.integer  "count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
