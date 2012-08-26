class CreateTimeEntries < ActiveRecord::Migration
  def change
    create_table :time_entries do |t|

      t.integer   :user_id
      t.integer   :project_id
      t.datetime  :start
      t.datetime  :end
      t.text      :note

      t.timestamps
    end
  end
end
