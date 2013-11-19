class ChangeLeadColumn < ActiveRecord::Migration
  def change
    change_table(:projects) do |t|
      t.remove :lead
      t.integer :lead_id
    end
  end
end
