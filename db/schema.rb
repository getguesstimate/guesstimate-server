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

ActiveRecord::Schema.define(version: 20160909215125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calculators", force: :cascade do |t|
    t.integer  "space_id"
    t.string   "title"
    t.text     "content"
    t.string   "input_ids",                array: true
    t.string   "output_ids",               array: true
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "share_image"
  end

  add_index "calculators", ["space_id"], name: "index_calculators_on_space_id", using: :btree

  create_table "fact_checkpoints", force: :cascade do |t|
    t.integer  "fact_id"
    t.integer  "author_id"
    t.json     "simulation"
    t.string   "name"
    t.string   "variable_name"
    t.string   "expression"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "fact_checkpoints", ["author_id"], name: "index_fact_checkpoints_on_author_id", using: :btree
  add_index "fact_checkpoints", ["created_at"], name: "index_fact_checkpoints_on_created_at", using: :btree
  add_index "fact_checkpoints", ["fact_id"], name: "index_fact_checkpoints_on_fact_id", using: :btree

  create_table "facts", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "variable_name"
    t.string   "expression"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.json     "simulation"
    t.integer  "exported_from_id"
    t.string   "metric_id"
  end

  add_index "facts", ["exported_from_id"], name: "index_facts_on_exported_from_id", using: :btree
  add_index "facts", ["organization_id"], name: "index_facts_on_organization_id", using: :btree

  create_table "organization_accounts", force: :cascade do |t|
    t.integer "organization_id"
    t.boolean "has_payment_account"
    t.string  "chargebee_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "picture"
    t.integer  "admin_id"
    t.integer  "plan",       default: 6
  end

  add_index "organizations", ["admin_id"], name: "index_organizations_on_admin_id", using: :btree

  create_table "space_checkpoints", force: :cascade do |t|
    t.json     "graph"
    t.string   "name"
    t.text     "description"
    t.integer  "space_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "author_id"
  end

  add_index "space_checkpoints", ["author_id"], name: "index_space_checkpoints_on_author_id", using: :btree
  add_index "space_checkpoints", ["created_at"], name: "index_space_checkpoints_on_created_at", using: :btree
  add_index "space_checkpoints", ["space_id"], name: "index_space_checkpoints_on_space_id", using: :btree

  create_table "spaces", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
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
    t.boolean  "is_recommended",         default: false
    t.integer  "exported_facts_count",   default: 0
    t.integer  "imported_fact_ids",                                   array: true
    t.string   "shareable_link_token"
    t.boolean  "shareable_link_enabled", default: false
  end

  add_index "spaces", ["imported_fact_ids"], name: "index_spaces_on_imported_fact_ids", using: :btree

  create_table "user_accounts", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "has_payment_account"
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
    t.integer  "plan",                 default: 1
    t.string   "email"
    t.string   "gender"
    t.string   "locale"
    t.string   "location"
    t.string   "company"
    t.string   "industry"
    t.string   "role"
    t.boolean  "categorized"
    t.boolean  "needs_tutorial",       default: false
  end

end
