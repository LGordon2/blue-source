class ChangeTypeOfScheduledhours < ActiveRecord::Migration
  def up
    change_column :employees, :scheduled_hours_start, :string
    change_column :employees, :scheduled_hours_end, :string
    Employee.where.not(scheduled_hours_start: nil).each do |e|
      e.update(scheduled_hours_start: e.scheduled_hours_start.to_time().strftime("%H:%M"))
    end
    Employee.where.not(scheduled_hours_end: nil).each do |e|
      e.update(scheduled_hours_end: e.scheduled_hours_end.to_time().strftime("%H:%M"))
    end
  end
  
  def down
    change_column :employees, :scheduled_hours_start, :time
    change_column :employees, :scheduled_hours_end, :time
  end
end
