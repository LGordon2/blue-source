class ChangeTypeOfTitle < ActiveRecord::Migration
  def change
    remove_column :employees, :title, :string
    add_column :employees, :title_id, :integer
  end
end
