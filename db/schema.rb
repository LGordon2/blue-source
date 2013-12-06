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

ActiveRecord::Schema.define(version: 20131206185440) do

  create_table "employees", force: true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.string   "role"
    t.datetime "start_date"
    t.integer  "extension"
    t.integer  "project_id"
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.datetime "start_date"
    t.datetime "projected_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lead_id"
    t.string   "status"
  end

  create_table "vacations", force: true do |t|
    t.date     "date_requested"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "vacation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_days"
    t.integer  "manager_id"
    t.integer  "employee_id"
  end

end
