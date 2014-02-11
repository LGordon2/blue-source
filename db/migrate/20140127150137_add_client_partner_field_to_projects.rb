class AddClientPartnerFieldToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :client_partner_id, :integer
  end
end
