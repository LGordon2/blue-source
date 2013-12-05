class ChangeDateReqToDateRequested < ActiveRecord::Migration
  def change
    rename_column :vacations, :date_req, :date_requested
  end
end
