class AddInfoToUser < ActiveRecord::Migration
  def change
    add_column :employees, :start_date, :datetime
    add_column :employees, :extension, :integer
  end
end
