class ChangeTypeOfTitle < ActiveRecord::Migration
  def self.up
   change_column :employees, :title, :integer
   rename_column :employees, :title, :title_id
  end

  def self.down
   change_column :employees, :title, :string
  end

end
