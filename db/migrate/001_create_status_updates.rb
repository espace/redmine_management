class CreateStatusUpdates < ActiveRecord::Migration
  def self.up
    create_table :status_updates do |t|
      t.integer :issue_id
      t.integer :old_status_id
      t.integer :new_status_id
      t.timestamps
    end
  end

  def self.down
    drop_table :status_updates
  end
end
