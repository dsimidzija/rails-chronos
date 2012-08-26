class RenameTimeFieldsInTimeEntry < ActiveRecord::Migration
  def change
    rename_column :time_entries, :start, :start_time
    rename_column :time_entries, :end, :end_time
  end
end
