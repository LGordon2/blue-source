class AddLeadToProjectHistory < ActiveRecord::Migration
  def change
    add_column :project_histories, :lead_id, :integer
  end
end
