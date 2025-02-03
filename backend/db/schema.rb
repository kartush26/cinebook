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

ActiveRecord::Schema[7.1].define(version: 2026_01_01_000014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "booking_seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "booking_id", null: false
    t.uuid "seat_id", null: false
    t.uuid "show_id", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_seats_on_booking_id"
    t.index ["seat_id"], name: "index_booking_seats_on_seat_id"
    t.index ["show_id", "seat_id"], name: "uniq_active_booking_seat", unique: true, where: "(active = true)"
    t.index ["show_id"], name: "index_booking_seats_on_show_id"
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "show_id", null: false
    t.string "reference", null: false
    t.integer "status", default: 0, null: false
    t.integer "seats_count", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "USD", null: false
    t.string "idempotency_key"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_bookings_on_idempotency_key", unique: true, where: "(idempotency_key IS NOT NULL)"
    t.index ["reference"], name: "index_bookings_on_reference", unique: true
    t.index ["show_id"], name: "index_bookings_on_show_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id", "created_at"], name: "index_bookings_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "featured_movies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "movie_id", null: false
    t.integer "position", null: false
    t.datetime "starts_on", null: false
    t.datetime "ends_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ends_on"], name: "index_featured_movies_on_ends_on"
    t.index ["movie_id"], name: "index_featured_movies_on_movie_id"
    t.index ["position", "starts_on"], name: "index_featured_movies_on_position_and_starts_on", unique: true
  end

  create_table "movies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "synopsis", default: "", null: false
    t.integer "duration_minutes", null: false
    t.string "language", null: false
    t.string "rating"
    t.string "genres", default: [], null: false, array: true
    t.string "cast", default: [], null: false, array: true
    t.string "director"
    t.string "trailer_url"
    t.date "release_date", null: false
    t.integer "status", default: 0, null: false
    t.decimal "imdb_rating", precision: 3, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genres"], name: "index_movies_on_genres", using: :gin
    t.index ["language"], name: "index_movies_on_language"
    t.index ["release_date"], name: "index_movies_on_release_date"
    t.index ["status"], name: "index_movies_on_status"
    t.index ["title"], name: "index_movies_on_title"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "booking_id", null: false
    t.string "provider", null: false
    t.string "external_id"
    t.string "client_secret"
    t.integer "status", default: 0, null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "USD", null: false
    t.string "idempotency_key", null: false
    t.jsonb "raw_payload", default: {}, null: false
    t.datetime "paid_at"
    t.datetime "refunded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["external_id"], name: "index_payments_on_external_id"
    t.index ["idempotency_key"], name: "index_payments_on_idempotency_key", unique: true
    t.index ["provider", "external_id"], name: "index_payments_on_provider_and_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token_digest", null: false
    t.string "jti", null: false
    t.string "family_id", null: false
    t.string "user_agent"
    t.string "ip"
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["family_id"], name: "index_refresh_tokens_on_family_id"
    t.index ["jti"], name: "index_refresh_tokens_on_jti", unique: true
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "screens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "theater_id", null: false
    t.string "name", null: false
    t.integer "rows", null: false
    t.integer "columns", null: false
    t.string "screen_type", default: "standard"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theater_id", "name"], name: "index_screens_on_theater_id_and_name", unique: true
    t.index ["theater_id"], name: "index_screens_on_theater_id"
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "screen_id", null: false
    t.string "row_label", null: false
    t.integer "column_index", null: false
    t.string "category", default: "standard", null: false
    t.decimal "base_price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_seats_on_category"
    t.index ["screen_id", "row_label", "column_index"], name: "index_seats_on_screen_id_and_row_label_and_column_index", unique: true
    t.index ["screen_id"], name: "index_seats_on_screen_id"
  end

  create_table "shows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "movie_id", null: false
    t.uuid "screen_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.decimal "price_multiplier", precision: 4, scale: 2, default: "1.0", null: false
    t.integer "status", default: 0, null: false
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id", "starts_at"], name: "index_shows_on_movie_id_and_starts_at"
    t.index ["movie_id"], name: "index_shows_on_movie_id"
    t.index ["screen_id", "starts_at"], name: "index_shows_on_screen_id_and_starts_at"
    t.index ["screen_id"], name: "index_shows_on_screen_id"
    t.index ["starts_at"], name: "index_shows_on_starts_at"
  end

  create_table "theaters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.string "address", null: false
    t.decimal "latitude", precision: 9, scale: 6
    t.decimal "longitude", precision: 9, scale: 6
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_theaters_on_active"
    t.index ["city", "name"], name: "index_theaters_on_city_and_name"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider", null: false
    t.string "external_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.text "error"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "external_id"], name: "index_webhook_events_on_provider_and_external_id", unique: true
    t.index ["status"], name: "index_webhook_events_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_seats", "bookings", on_delete: :cascade
  add_foreign_key "booking_seats", "seats", on_delete: :restrict
  add_foreign_key "booking_seats", "shows", on_delete: :restrict
  add_foreign_key "bookings", "shows", on_delete: :restrict
  add_foreign_key "bookings", "users", on_delete: :restrict
  add_foreign_key "featured_movies", "movies", on_delete: :cascade
  add_foreign_key "payments", "bookings", on_delete: :cascade
  add_foreign_key "refresh_tokens", "users", on_delete: :cascade
  add_foreign_key "screens", "theaters", on_delete: :cascade
  add_foreign_key "seats", "screens", on_delete: :cascade
  add_foreign_key "shows", "movies", on_delete: :restrict
  add_foreign_key "shows", "screens", on_delete: :restrict
end
