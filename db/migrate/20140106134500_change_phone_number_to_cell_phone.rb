class ChangePhoneNumberToCellPhone < ActiveRecord::Migration
  def change
    rename_column :employees, :phone_number, :cell_phone
  end
end
