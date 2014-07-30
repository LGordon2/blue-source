class ChangeDepartmentFromStringToReferences < ActiveRecord::Migration
  def change
    change_table 'employees' do |t|
      t.references 'department'
    end
  end
end
