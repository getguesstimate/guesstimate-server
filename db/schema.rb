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

ActiveRecord::Schema.define(version: 2016_12_14_161326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calculators", id: :serial, force: :cascade do |t|
    t.integer "space_id"
    t.string "title"
    t.text "content"
    t.string "input_ids", array: true
    t.string "output_ids", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "share_image"
    t.index ["space_id"], name: "index_calculators_on_space_id"
  end

  create_table "fact_categories", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_fact_categories_on_organization_id"
  end

  create_table "fact_checkpoints", id: :serial, force: :cascade do |t|
    t.integer "fact_id"
    t.integer "author_id"
    t.json "simulation"
    t.string "name"
    t.string "variable_name"
    t.string "expression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "by_api"
    t.index ["author_id"], name: "index_fact_checkpoints_on_author_id"
    t.index ["created_at"], name: "index_fact_checkpoints_on_created_at"
    t.index ["fact_id"], name: "index_fact_checkpoints_on_fact_id"
  end

  create_table "facts", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.string "variable_name"
    t.string "expression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "simulation"
    t.integer "exported_from_id"
    t.string "metric_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_facts_on_category_id"
    t.index ["exported_from_id"], name: "index_facts_on_exported_from_id"
    t.index ["organization_id"], name: "index_facts_on_organization_id"
  end

  create_table "organization_accounts", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.boolean "has_payment_account"
    t.string "chargebee_id"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "picture"
    t.integer "admin_id"
    t.integer "plan", default: 6
    t.string "api_token"
    t.boolean "api_enabled"
    t.index ["admin_id"], name: "index_organizations_on_admin_id"
  end

  create_table "space_checkpoints", id: :serial, force: :cascade do |t|
    t.json "graph"
    t.string "name"
    t.text "description"
    t.integer "space_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id"
    t.index ["author_id"], name: "index_space_checkpoints_on_author_id"
    t.index ["created_at"], name: "index_space_checkpoints_on_created_at"
    t.index ["space_id"], name: "index_space_checkpoints_on_space_id"
  end

  create_table "spaces", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "graph"
    t.integer "user_id"
    t.boolean "is_private"
    t.integer "copied_from_id"
    t.integer "viewcount"
    t.integer "organization_id"
    t.string "category"
    t.string "screenshot"
    t.boolean "categorized"
    t.datetime "snapshot_timestamp"
    t.string "big_screenshot"
    t.boolean "is_recommended", default: false
    t.integer "exported_facts_count", default: 0
    t.integer "imported_fact_ids", array: true
    t.string "shareable_link_token"
    t.boolean "shareable_link_enabled", default: false
    t.index ["imported_fact_ids"], name: "index_spaces_on_imported_fact_ids"
  end

  create_table "user_accounts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "has_payment_account"
  end

  create_table "user_organization_invitations", id: :serial, force: :cascade do |t|
    t.string "email"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_user_organization_invitations_on_email"
    t.index ["organization_id"], name: "index_user_organization_invitations_on_organization_id"
  end

  create_table "user_organization_memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invitation_id"
    t.index ["organization_id"], name: "index_user_organization_memberships_on_organization_id"
    t.index ["user_id"], name: "index_user_organization_memberships_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "picture"
    t.string "auth0_id"
    t.string "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "private_access_count"
    t.integer "plan", default: 1
    t.string "email"
    t.string "gender"
    t.string "locale"
    t.string "location"
    t.string "company"
    t.string "industry"
    t.string "role"
    t.boolean "categorized"
    t.boolean "needs_tutorial", default: false
  end

end
