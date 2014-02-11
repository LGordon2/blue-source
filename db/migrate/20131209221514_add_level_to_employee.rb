class AddLevelToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :level, :string
  end
end
