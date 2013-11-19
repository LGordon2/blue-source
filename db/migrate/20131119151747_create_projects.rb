class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :lead
      t.datetime :start_date
      t.datetime :projected_end

      t.timestamps
    end
  end
end
