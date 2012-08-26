class AddEntryDateToTimeEntry < ActiveRecord::Migration
  def up
    add_column :time_entries, :entry_date, :date

    change_column :time_entries, :start_time, :time
    change_column :time_entries, :end_time, :time
  end

  def down
    remove_column :time_entries, :entry_date

    change_column :time_entries, :start_time, :datetime
    change_column :time_entries, :end_time, :datetime
  end
end
