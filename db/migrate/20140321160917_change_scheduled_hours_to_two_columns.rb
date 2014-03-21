class ChangeScheduledHoursToTwoColumns < ActiveRecord::Migration
  def change
    remove_column :project_histories, :scheduled_hours
    add_column :project_histories, :scheduled_hours_start, :time
    add_column :project_histories, :scheduled_hours_end, :time
  end
end
