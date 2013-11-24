class AddProjectToUsers < ActiveRecord::Migration
  def change
    add_column :employees, :project, :string
  end
end
