class ChangeDepartmentsTable < ActiveRecord::Migration
  def change
    change_table :departments do |t|
      t.references :department, index: true
    end
  end
end
