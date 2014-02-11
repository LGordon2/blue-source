class AddHalfDayToVacation < ActiveRecord::Migration
  def change
    add_column :vacations, :half_day, :boolean
  end
end
