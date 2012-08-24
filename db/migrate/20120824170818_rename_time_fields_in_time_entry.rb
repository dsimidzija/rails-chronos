class RenameTimeFieldsInTimeEntry < ActiveRecord::Migration
  def up
    rename_column :time_entries, :start, :start_time
    rename_column :time_entries, :end, :end_time
  end

  def down
    rename_column :time_entries, :start_time, :start
    rename_column :time_entries, :end_time, :end
  end
end
