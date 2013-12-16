class AddFieldsToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :phone_number, :string
    add_column :employees, :im_name, :string
    add_column :employees, :im_client, :string
  end
end
