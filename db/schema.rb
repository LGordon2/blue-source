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

ActiveRecord::Schema.define(version: 20140205192134) do

  create_table "departments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
  end

  add_index "departments", ["department_id"], name: "index_departments_on_department_id"
  
  create_table "employees", force: true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.string   "role"
    t.date     "start_date"
    t.integer  "project_id"
    t.string   "level"
    t.string   "cell_phone"
    t.string   "im_name"
    t.string   "im_client"
    t.string   "status"
    t.date     "roll_on_date"
    t.date     "roll_off_date"
    t.string   "email"
    t.string   "office_phone"
    t.integer  "team_lead_id"
    t.string   "location"
    t.string   "department"
    t.integer  "department_id"
  end

  create_table "project_leads", force: true do |t|
    t.integer  "project_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_leads", ["employee_id"], name: "index_project_leads_on_employee_id"
  add_index "project_leads", ["project_id"], name: "index_project_leads_on_project_id"

  create_table "projects", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "client_partner_id"
  end

  create_table "vacations", force: true do |t|
    t.date     "date_requested"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "vacation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "business_days"
    t.integer  "manager_id"
    t.integer  "employee_id"
    t.boolean  "half_day"
    t.string   "reason"
    t.string   "status"
  end

end
