class AddInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :start_date, :datetime
    add_column :users, :extension, :integer
  end
end
