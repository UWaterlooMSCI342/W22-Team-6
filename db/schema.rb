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

ActiveRecord::Schema.define(version: 2021_04_04_164701) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.integer "participation_rating", null: false
    t.integer "effort_rating", null: false
    t.integer "punctuality_rating", null: false
    t.string "comments", limit: 2048
    t.datetime "timestamp", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "team_id"
    t.bigint "user_id"
    t.integer "priority", default: 2, null: false
    t.index ["team_id"], name: "index_feedbacks_on_team_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "admin_code", limit: 10, default: "admin"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_code"
    t.string "team_name"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_code"], name: "index_teams_on_team_code", unique: true
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "teams_users", id: false, force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_id"], name: "index_teams_users_on_team_id"
    t.index ["user_id"], name: "index_teams_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "security_q_one", limit: 255
    t.string "security_q_two", limit: 255
    t.string "security_q_three", limit: 255
    t.boolean "is_admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "feedbacks", "teams"
  add_foreign_key "feedbacks", "users", on_delete: :cascade
  add_foreign_key "teams", "users", on_delete: :cascade
  add_foreign_key "teams_users", "teams"
  add_foreign_key "teams_users", "users"
end
