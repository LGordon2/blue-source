class RenameMemoColumnToCommentsAndAddScheduledHours < ActiveRecord::Migration
  def change
    remove_column :projects, :memo, :text
    add_column :employees, :project_comments, :text
    add_column :employees, :scheduled_hours_start, :time
    add_column :employees, :scheduled_hours_end, :time
  end
end
