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

ActiveRecord::Schema.define(version: 20160214213211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "badges", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "why"
    t.string   "image_name"
    t.string   "provider"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "protip_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "likes_count", default: 0
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "likable_id"
    t.integer  "user_id"
    t.string   "likable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "likes", ["user_id", "likable_type", "likable_id"], name: "index_likes_on_user_id_and_likable_type_and_likable_id", unique: true, using: :btree

  create_table "protips", force: :cascade do |t|
    t.string   "public_id"
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.integer  "user_id"
    t.float    "score"
    t.datetime "featured_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "tags",        default: [],                 array: true
    t.integer  "likes_count", default: 0
    t.integer  "views_count", default: 0
    t.boolean  "flagged",     default: false
  end

  add_index "protips", ["tags"], name: "index_protips_on_tags", using: :gin

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "avatar"
    t.string   "title"
    t.string   "location"
    t.string   "country"
    t.string   "city"
    t.string   "state_name"
    t.string   "company"
    t.text     "about"
    t.integer  "team_id"
    t.string   "api_key"
    t.boolean  "admin"
    t.boolean  "receive_newsletter",                default: true
    t.boolean  "receive_weekly_digest",             default: true
    t.integer  "last_ip"
    t.datetime "last_email_sent"
    t.datetime "last_request_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.citext   "username"
    t.citext   "email"
    t.string   "encrypted_password",    limit: 128
    t.string   "confirmation_token",    limit: 128
    t.string   "remember_token",        limit: 128
    t.string   "skills",                            default: [],                  array: true
    t.string   "github_id"
    t.string   "twitter_id"
    t.string   "github"
    t.string   "twitter"
    t.string   "color",                             default: "#111"
    t.integer  "karma",                             default: 1
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["skills"], name: "index_users_on_skills", using: :gin

end
