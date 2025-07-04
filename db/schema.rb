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

ActiveRecord::Schema[8.0].define(version: 2025_06_23_013031) do
  create_schema "cable"
  create_schema "cache"
  create_schema "queue"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ad_requests", force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.bigint "publisher_id", null: false
    t.string "status", default: "pending"
    t.datetime "requested_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_id", "publisher_id"], name: "index_ad_requests_on_ad_id_and_publisher_id", unique: true
    t.index ["ad_id"], name: "index_ad_requests_on_ad_id"
    t.index ["publisher_id"], name: "index_ad_requests_on_publisher_id"
  end

  create_table "ads", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "ad_format"
    t.string "ad_size"
    t.string "custom_width"
    t.string "custom_height"
    t.text "ad_txt_content"
    t.text "header_code"
    t.boolean "header_bidding"
    t.text "header_bidding_partners"
    t.boolean "fallback_image"
    t.date "start_date"
    t.date "end_date"
    t.decimal "budget"
    t.string "bid_strategy"
    t.text "target_audience"
    t.text "target_locations"
    t.string "target_devices"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "password_digest"
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ga_refresh_token"
    t.string "ga_property_id"
    t.string "company_name"
    t.string "contact_name"
    t.string "contact_title"
    t.string "address"
    t.string "website"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ad_requests", "ads"
  add_foreign_key "ad_requests", "users", column: "publisher_id"
  add_foreign_key "ads", "users"
end
