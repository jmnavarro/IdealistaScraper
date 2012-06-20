# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090814230235) do

  create_table "flats", :force => true do |t|
    t.text     "url"
    t.string   "address"
    t.decimal  "latitude",                    :precision => 15, :scale => 10
    t.decimal  "longitude",                   :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "spider"
    t.boolean  "active"
    t.string   "kind",          :limit => 3
    t.string   "external_id"
    t.string   "contact_phone", :limit => 16
    t.integer  "price"
    t.integer  "rooms"
    t.integer  "area"
    t.string   "region"
    t.string   "postal_code",   :limit => 16
    t.string   "region_code",   :limit => 4
  end

  add_index "flats", ["active"], :name => "flats_active_idx"
  add_index "flats", ["area"], :name => "flats_area_idx"
  add_index "flats", ["city", "postal_code"], :name => "flats_place4_idx"
  add_index "flats", ["city"], :name => "flats_city_idx"
  add_index "flats", ["kind"], :name => "flats_kind_idx"
  add_index "flats", ["latitude", "longitude"], :name => "flats_location_idx"
  add_index "flats", ["latitude"], :name => "flats_lat_idx"
  add_index "flats", ["longitude"], :name => "flats_lon_idx"
  add_index "flats", ["postal_code"], :name => "flats_postal_code_idx"
  add_index "flats", ["price"], :name => "flats_price_idx"
  add_index "flats", ["region", "city", "postal_code"], :name => "flats_place_idx"
  add_index "flats", ["region", "city"], :name => "flats_place2_idx"
  add_index "flats", ["region", "postal_code"], :name => "flats_place3_idx"
  add_index "flats", ["region"], :name => "flats_region_idx"
  add_index "flats", ["region_code"], :name => "flats_region_code_idx"
  add_index "flats", ["rooms"], :name => "flats_rooms_idx"
  add_index "flats", ["spider", "external_id"], :name => "flats_spider_external_id_idx", :unique => true

  create_table "flats_back", :force => true do |t|
    t.text     "url"
    t.string   "address"
    t.decimal  "latitude",                    :precision => 15, :scale => 10
    t.decimal  "longitude",                   :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "spider"
    t.boolean  "active"
    t.string   "kind",          :limit => 3
    t.string   "external_id"
    t.string   "contact_phone", :limit => 16
    t.integer  "price"
  end

end
