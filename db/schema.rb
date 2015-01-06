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

ActiveRecord::Schema.define(version: 20150105144204) do

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.datetime "date"
    t.string   "activity"
    t.string   "group"
    t.float    "total_duration"
    t.float    "distance"
    t.integer  "steps"
    t.float    "calories"
    t.datetime "synced_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "soft_duration"
    t.float    "moderate_duration"
    t.float    "hard_duration"
    t.float    "elevation"
    t.boolean  "sync_final"
  end

  add_index "activities", ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at"
  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "connections", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "connections", ["name", "user_id"], name: "index_connection_on_name_and_user_id", unique: true

  create_table "friendships", force: true do |t|
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.boolean  "authorized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user1_id", "user2_id"], name: "index_friendships_on_user1_id_and_user2_id"

  create_table "measurements", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.datetime "date"
    t.integer  "diastolicbp"
    t.integer  "systolicbp"
    t.integer  "pulse"
    t.integer  "SPO2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "measurements", ["user_id", "created_at"], name: "index_measurements_on_user_id_and_created_at"
  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id"

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "detail"
    t.string   "notification_type"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notification_data"
  end

  add_index "notifications", ["user_id", "date"], name: "index_notifications_on_user_id_and_date"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name",                            null: false
    t.string   "username",                        null: false
    t.string   "email",                           null: false
    t.string   "crypted_password",                null: false
    t.string   "salt",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "connection_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token"

end
