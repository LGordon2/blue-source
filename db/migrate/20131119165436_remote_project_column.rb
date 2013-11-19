class RemoteProjectColumn < ActiveRecord::Migration
  def change
    change_table(:employees) do |t|
      t.remove :project
    end
  end
end
