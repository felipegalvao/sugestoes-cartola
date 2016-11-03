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

ActiveRecord::Schema.define(version: 20161103172027) do

  create_table "players", force: :cascade do |t|
    t.string   "nickname"
    t.string   "player_id"
    t.string   "position"
    t.decimal  "price",            precision: 6, scale: 2
    t.decimal  "score",            precision: 6, scale: 2
    t.integer  "clean_sheets"
    t.integer  "penalty_defenses"
    t.integer  "good_saves"
    t.integer  "ball_steals"
    t.integer  "own_goals"
    t.integer  "red_cards"
    t.integer  "yellow_cards"
    t.integer  "goals_against"
    t.integer  "fouls_committed"
    t.integer  "goals"
    t.integer  "assists"
    t.integer  "shots_on_the_bar"
    t.integer  "shots_defended"
    t.integer  "shots_off_target"
    t.integer  "fouls_suffered"
    t.integer  "penalties_lost"
    t.integer  "offsides"
    t.integer  "missed_passes"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "games"
    t.decimal  "score_per_price",  precision: 6, scale: 2
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin",                  default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
