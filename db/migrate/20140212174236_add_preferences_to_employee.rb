class AddPreferencesToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :preferences, :text
  end
end
