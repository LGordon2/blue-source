class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.string :column_name
      t.string :operator
      t.string :text
      
      t.timestamps
    end
  end
end
