class AddManagerIdToUser < ActiveRecord::Migration
  def change
    add_column :employees, :manager_id, :integer
  end
end
