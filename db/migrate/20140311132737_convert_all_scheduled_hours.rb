class ConvertAllScheduledHours < ActiveRecord::Migration
  def change
    Employee.all.each do |employee|
      unless employee.scheduled_hours_start.blank?
        employee.update(scheduled_hours_start: Time.parse(employee.scheduled_hours_start).to_s(:form_time))
      end

      unless employee.scheduled_hours_end.blank?
        employee.update(scheduled_hours_end: Time.parse(employee.scheduled_hours_end).to_s(:form_time))
      end
    end
  end
end
