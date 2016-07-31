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

ActiveRecord::Schema.define(version: 20160730181928) do

  create_table "context_texts", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "title",       limit: 255
    t.text     "whole_text",  limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "language_id", limit: 4
    t.integer  "user_id",     limit: 4
    t.boolean  "is_public"
  end

  add_index "context_texts", ["language_id"], name: "index_context_texts_on_language_id", using: :btree
  add_index "context_texts", ["user_id"], name: "index_context_texts_on_user_id", using: :btree

  create_table "language_context_texts", force: :cascade do |t|
    t.integer "language_id",     limit: 4
    t.integer "context_text_id", limit: 4
  end

  add_index "language_context_texts", ["context_text_id"], name: "index_language_context_texts_on_context_text_id", using: :btree
  add_index "language_context_texts", ["language_id"], name: "index_language_context_texts_on_language_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "languages_users", force: :cascade do |t|
    t.integer "user_id",     limit: 4
    t.integer "language_id", limit: 4
  end

  add_index "languages_users", ["language_id"], name: "index_languages_users_on_language_id", using: :btree
  add_index "languages_users", ["user_id"], name: "index_languages_users_on_user_id", using: :btree

  create_table "rest_access_tokens", force: :cascade do |t|
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "token",      limit: 255
    t.string   "secret",     limit: 255
  end

  add_index "rest_access_tokens", ["user_id"], name: "index_rest_access_tokens_on_user_id", using: :btree

  create_table "text_element_context_texts", force: :cascade do |t|
    t.integer "text_element_id", limit: 4
    t.integer "context_text_id", limit: 4
  end

  add_index "text_element_context_texts", ["context_text_id"], name: "index_text_element_context_texts_on_context_text_id", using: :btree
  add_index "text_element_context_texts", ["text_element_id"], name: "index_text_element_context_texts_on_text_element_id", using: :btree

  create_table "text_elements", force: :cascade do |t|
    t.string   "value",          limit: 255
    t.string   "part_of_speech", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "language_id",    limit: 4
  end

  add_index "text_elements", ["language_id"], name: "index_text_elements_on_language_id", using: :btree

  create_table "trainings", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.string   "state",      limit: 255
    t.text     "json_data",  limit: 65535
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "trainings", ["user_id"], name: "index_trainings_on_user_id", using: :btree

  create_table "translation_in_context_texts", force: :cascade do |t|
    t.integer  "position",         limit: 4
    t.integer  "selection_length", limit: 4
    t.integer  "translation_id",   limit: 4
    t.integer  "context_text_id",  limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id",          limit: 4
  end

  add_index "translation_in_context_texts", ["context_text_id"], name: "index_translation_in_context_texts_on_context_text_id", using: :btree
  add_index "translation_in_context_texts", ["translation_id"], name: "index_translation_in_context_texts_on_translation_id", using: :btree
  add_index "translation_in_context_texts", ["user_id"], name: "index_translation_in_context_texts_on_user_id", using: :btree

  create_table "translations", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "original_id",       limit: 4
    t.integer  "translated_one_id", limit: 4
  end

  add_index "translations", ["original_id"], name: "index_translations_on_original_id", using: :btree
  add_index "translations", ["translated_one_id"], name: "index_translations_on_translated_one_id", using: :btree

  create_table "user_translations", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "translation_id",   limit: 4
    t.string   "learning_stage",   limit: 255
    t.datetime "next_training_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "training_history", limit: 65535
  end

  add_index "user_translations", ["translation_id"], name: "index_user_translations_on_translation_id", using: :btree
  add_index "user_translations", ["user_id"], name: "index_user_translations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255
    t.string   "singed_via",             limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "authentication_token",   limit: 255
    t.integer  "age",                    limit: 4
    t.string   "about",                  limit: 255
    t.integer  "min_starts",             limit: 4
    t.integer  "day_words",              limit: 4
    t.text     "json_data",              limit: 65535
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "context_texts", "languages"
  add_foreign_key "context_texts", "users"
  add_foreign_key "language_context_texts", "context_texts"
  add_foreign_key "language_context_texts", "languages"
  add_foreign_key "languages_users", "languages"
  add_foreign_key "languages_users", "users"
  add_foreign_key "rest_access_tokens", "users"
  add_foreign_key "text_element_context_texts", "context_texts"
  add_foreign_key "text_element_context_texts", "text_elements"
  add_foreign_key "text_elements", "languages"
  add_foreign_key "trainings", "users"
  add_foreign_key "translation_in_context_texts", "context_texts"
  add_foreign_key "translation_in_context_texts", "translations"
  add_foreign_key "translation_in_context_texts", "users"
  add_foreign_key "translations", "text_elements", column: "original_id"
  add_foreign_key "translations", "text_elements", column: "translated_one_id"
  add_foreign_key "user_translations", "translations"
  add_foreign_key "user_translations", "users"
end
