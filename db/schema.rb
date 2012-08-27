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

ActiveRecord::Schema.define(:version => 20120825121844) do

  create_table "projects", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.time     "start_time"
    t.time     "end_time"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "entry_date"
  end

  add_index "time_entries", ["user_id", "entry_date"], :name => "index_time_entries_on_user_id_and_entry_date"
  add_index "time_entries", ["user_id", "project_id", "entry_date"], :name => "index_time_entries_on_user_id_and_project_id_and_entry_date"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "salt"
    t.string   "encrypted_password", :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
