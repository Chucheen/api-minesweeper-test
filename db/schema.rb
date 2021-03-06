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

ActiveRecord::Schema.define(version: 20190407161712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_cells", force: :cascade do |t|
    t.string "coordinates"
    t.string "status", default: "closed"
    t.boolean "has_mine", default: true
    t.bigint "game_id"
    t.index ["game_id"], name: "index_game_cells_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "finished_at"
    t.datetime "started_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "status"
    t.string "started"
    t.integer "cells_long"
    t.datetime "paused_at"
    t.integer "played_time"
    t.integer "number_of_mines"
    t.datetime "resumed_at"
  end

  add_foreign_key "game_cells", "games"
end
