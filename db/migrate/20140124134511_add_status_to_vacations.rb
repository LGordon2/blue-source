class AddStatusToVacations < ActiveRecord::Migration
  def change
    add_column :vacations, :status, :string
  end
end
