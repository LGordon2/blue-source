class CreateProjectLeads < ActiveRecord::Migration
  def change
    create_table :project_leads do |t|
      t.references :project, index: true
      t.references :employee, index: true

      t.timestamps
    end
  end
end
