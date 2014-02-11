class ChangeExtensionToOfficePhone < ActiveRecord::Migration
  def change
    remove_column :employees, :extension
    add_column :employees, :office_phone, :string
  end
end
