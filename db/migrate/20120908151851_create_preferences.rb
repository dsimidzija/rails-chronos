class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|

      t.integer :user_id
      t.string  :name
      t.string  :value

      t.timestamps
    end

    add_index :preferences, [:user_id, :name], :unique => true
  end
end
