class AddStatusAndStartedAtToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :status, :integer, default: 0, null: false
    add_column :rooms, :started_at, :datetime
    add_index :rooms, :status
  end
end