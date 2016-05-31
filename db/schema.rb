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

ActiveRecord::Schema.define(version: 20160529233942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "has_payment_account"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "picture"
    t.integer  "admin_id"
  end

  add_index "organizations", ["admin_id"], name: "index_organizations_on_admin_id", using: :btree

  create_table "space_checkpoints", force: :cascade do |t|
    t.json     "graph"
    t.string   "name"
    t.text     "description"
    t.integer  "space_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "space_checkpoints", ["created_at"], name: "index_space_checkpoints_on_created_at", using: :btree
  add_index "space_checkpoints", ["space_id"], name: "index_space_checkpoints_on_space_id", using: :btree

  create_table "spaces", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.json     "graph"
    t.integer  "user_id"
    t.boolean  "is_private"
    t.integer  "copied_from_id"
    t.integer  "viewcount"
    t.integer  "organization_id"
    t.string   "category"
    t.string   "screenshot"
    t.boolean  "categorized"
    t.datetime "snapshot_timestamp"
    t.string   "big_screenshot"
  end

  create_table "user_organization_invitations", force: :cascade do |t|
    t.string   "email"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_organization_invitations", ["email"], name: "index_user_organization_invitations_on_email", using: :btree
  add_index "user_organization_invitations", ["organization_id"], name: "index_user_organization_invitations_on_organization_id", using: :btree

  create_table "user_organization_memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "invitation_id"
  end

  add_index "user_organization_memberships", ["organization_id"], name: "index_user_organization_memberships_on_organization_id", using: :btree
  add_index "user_organization_memberships", ["user_id"], name: "index_user_organization_memberships_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "picture"
    t.string   "auth0_id"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "private_access_count"
    t.boolean  "has_private_access"
    t.integer  "plan",                 default: 1
    t.string   "email"
    t.string   "gender"
    t.string   "locale"
    t.string   "location"
    t.string   "company"
    t.string   "industry"
    t.string   "role"
    t.boolean  "categorized"
    t.integer  "sign_in_count",        default: 0, null: false
  end

end
