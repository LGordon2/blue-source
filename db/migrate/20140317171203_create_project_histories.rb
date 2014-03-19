class CreateProjectHistories < ActiveRecord::Migration
  def change
    create_table :project_histories do |t|
      t.integer  "project_id",      null: false
      t.integer  "employee_id",     null: false
      t.date "roll_on_date"
      t.date "roll_off_date"
      t.integer "scheduled_hours"
      t.text "memo"
      t.timestamps
    end
  end
end
