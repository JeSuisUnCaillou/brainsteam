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

ActiveRecord::Schema.define(version: 20140403161456) do

  create_table "messages", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "threadhead_id"
  end

  add_index "messages", ["user_id"], name: "index_messages_on_user_id"

  create_table "paths", force: true do |t|
    t.integer  "user_id"
    t.integer  "threadhead_id"
    t.integer  "treenode_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",        default: true
  end

  add_index "paths", ["threadhead_id", "user_id"], name: "index_paths_on_threadhead_id_and_user_id"
  add_index "paths", ["treenode_id", "user_id"], name: "index_paths_on_treenode_id_and_user_id", unique: true
  add_index "paths", ["user_id"], name: "index_paths_on_user_id"

  create_table "thread_tag_relationships", force: true do |t|
    t.integer  "threadhead_id"
    t.integer  "thread_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thread_tag_relationships", ["thread_tag_id"], name: "index_thread_tag_relationships_on_thread_tag_id"
  add_index "thread_tag_relationships", ["threadhead_id"], name: "index_thread_tag_relationships_on_threadhead_id"

  create_table "thread_tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "thread_tags", ["name"], name: "index_thread_tags_on_name", unique: true

  create_table "threadheads", force: true do |t|
    t.boolean  "private",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_message_date"
  end

  create_table "treenodes", force: true do |t|
    t.integer  "obj_id"
    t.string   "obj_type"
    t.integer  "parent_node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "treenodes", ["obj_id", "obj_type"], name: "index_treenodes_on_obj_id_and_obj_type", unique: true
  add_index "treenodes", ["parent_node_id"], name: "index_treenodes_on_parent_node_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["name"], name: "index_users_on_name", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
