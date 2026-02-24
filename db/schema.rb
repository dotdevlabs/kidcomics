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

ActiveRecord::Schema[8.1].define(version: 2026_02_24_182820) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.boolean "ai_generation_enabled", default: true, null: false
    t.bigint "child_profile_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "favorited", default: false, null: false
    t.datetime "last_generated_at"
    t.string "preferred_style"
    t.string "status", default: "draft", null: false
    t.text "story_prompt"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["child_profile_id", "created_at"], name: "index_books_on_child_profile_id_and_created_at"
    t.index ["child_profile_id"], name: "index_books_on_child_profile_id"
    t.index ["favorited"], name: "index_books_on_favorited"
    t.index ["last_generated_at"], name: "index_books_on_last_generated_at"
    t.index ["status"], name: "index_books_on_status"
    t.index ["view_count"], name: "index_books_on_view_count"
  end

  create_table "character_extractions", force: :cascade do |t|
    t.string "character_name"
    t.jsonb "color_palette", default: {}
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "drawing_id", null: false
    t.jsonb "proportions", default: {}
    t.integer "status", default: 0, null: false
    t.bigint "story_generation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["drawing_id", "story_generation_id"], name: "index_character_extractions_on_drawing_and_story_gen", unique: true
    t.index ["drawing_id"], name: "index_character_extractions_on_drawing_id"
    t.index ["status"], name: "index_character_extractions_on_status"
    t.index ["story_generation_id"], name: "index_character_extractions_on_story_generation_id"
  end

  create_table "child_profiles", force: :cascade do |t|
    t.integer "age"
    t.datetime "created_at", null: false
    t.bigint "family_account_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["family_account_id"], name: "index_child_profiles_on_family_account_id"
  end

  create_table "drawings", force: :cascade do |t|
    t.jsonb "analysis_data", default: {}
    t.integer "analysis_status", default: 0
    t.bigint "book_id", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "extracted_at"
    t.boolean "is_background", default: false
    t.boolean "is_character", default: false
    t.integer "position", null: false
    t.string "tag"
    t.datetime "updated_at", null: false
    t.index ["analysis_status"], name: "index_drawings_on_analysis_status"
    t.index ["book_id", "position"], name: "index_drawings_on_book_id_and_position"
    t.index ["book_id"], name: "index_drawings_on_book_id"
    t.index ["is_background"], name: "index_drawings_on_is_background"
    t.index ["is_character"], name: "index_drawings_on_is_character"
  end

  create_table "family_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_family_accounts_on_owner_id"
  end

  create_table "page_generations", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.integer "cost_cents", default: 0
    t.datetime "created_at", null: false
    t.jsonb "dialogue_data", default: {}
    t.text "error_message"
    t.string "generated_image_url"
    t.float "generation_time_seconds"
    t.text "narration_text"
    t.integer "page_number", null: false
    t.jsonb "panel_layout", default: {}
    t.text "prompt"
    t.integer "reference_drawing_ids", default: [], array: true
    t.integer "retry_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "story_generation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_page_generations_on_book_id"
    t.index ["page_number"], name: "index_page_generations_on_page_number"
    t.index ["status"], name: "index_page_generations_on_status"
    t.index ["story_generation_id", "page_number"], name: "index_page_generations_on_story_generation_id_and_page_number", unique: true
    t.index ["story_generation_id"], name: "index_page_generations_on_story_generation_id"
  end

  create_table "story_generations", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.jsonb "character_data", default: {}
    t.datetime "completed_at"
    t.integer "cost_cents", default: 0
    t.datetime "created_at", null: false
    t.text "error_message"
    t.jsonb "generation_metadata", default: {}
    t.text "prompt_template"
    t.integer "status", default: 0, null: false
    t.text "story_outline"
    t.jsonb "style_data", default: {}
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_story_generations_on_book_id"
    t.index ["completed_at"], name: "index_story_generations_on_completed_at"
    t.index ["status"], name: "index_story_generations_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "books", "child_profiles"
  add_foreign_key "character_extractions", "drawings"
  add_foreign_key "character_extractions", "story_generations"
  add_foreign_key "child_profiles", "family_accounts"
  add_foreign_key "drawings", "books"
  add_foreign_key "family_accounts", "users", column: "owner_id"
  add_foreign_key "page_generations", "books"
  add_foreign_key "page_generations", "story_generations"
  add_foreign_key "story_generations", "books"
end
