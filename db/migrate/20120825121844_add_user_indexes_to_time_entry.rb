class AddUserIndexesToTimeEntry < ActiveRecord::Migration
  def change
    add_index :time_entries, [:user_id, :project_id, :entry_date]
    add_index :time_entries, [:user_id, :entry_date]
  end
end
