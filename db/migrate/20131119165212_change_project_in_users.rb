class ChangeProjectInUsers < ActiveRecord::Migration
  def change
    change_table(:employees) do |t|
      t.belongs_to :project 
    end
  end
end
